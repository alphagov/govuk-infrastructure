require "aws-sdk-s3"
require "aws-sdk-secretsmanager"
require "json"
require "logger"
require "net/http"
require "securerandom"
require "uri"

class SignonClient
  ENDPOINT = ENV.fetch("SIGNON_API_URL")

  def initialize(api_user:, auth_token:, logger: Logger.new($stdout), max_retries: 9)
    @api_user = api_user
    @auth_token = auth_token
    @max_retries = max_retries
    @logger = logger
  end

  def create_bearer_token(application_name:, permissions:)
    attempt do
      uri = URI("#{ENDPOINT}/authorisations")
      req = Net::HTTP::Post.new(uri)
      req.body = {
        api_user_email: @api_user,
        application_name: application_name,
        permissions: permissions,
      }.to_json
      res = do_request(req, uri)
      raise TokenNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless %w[200 201].include?(res.code)

      JSON.parse(res.body).fetch("token")
    end
  end

  def test_bearer_token(token:, application_name:, permissions:)
    attempt do
      uri = URI("#{ENDPOINT}/authorisations/test")
      req = Net::HTTP::Post.new(uri)
      req.body = {
        token: token,
        api_user_email: @api_user,
        application_name: application_name,
        permissions: permissions,
      }.to_json
      res = do_request(req, uri)
      raise TokenNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"
    end
  end

private

  class TokenNotFound < StandardError; end

  class TokenNotCreated < StandardError; end

  def attempt(&request)
    retries ||= 0
    begin
      yield request
    rescue TokenNotFound, TokenNotCreated
      if (retries += 1) <= @max_retries
        @logger.info "Rescued failed attempt. Attempts remaining: #{@max_retries - retries}."
        sleep(2**retries)
        retry
      else
        @logger.info "#{@max_retries} attempts failed. Bailing out."
        raise
      end
    end
  end

  def do_request(request, uri)
    request["Authorization"] = "Bearer #{@auth_token}"
    request["Content-Type"] = "application/json"
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
  end
end

class HandlerError < StandardError; end

class InvalidVersion < HandlerError; end

class UnknownVersion < InvalidVersion; end

class NotRotatable < HandlerError; end

class NotPendingVersion < InvalidVersion; end

# Event handler called by SecretsManager
# @event: {
#   "SecretId" => "The secret ARN or identifier",
#   "ClientRequestToken" => "The ClientRequestToken of the secret version",
#   "Step" => "The rotation step (one of createSecret, setSecret, testSecret, or finishSecret)",
# }
# @context: https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html
def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  logger = Logger.new($stdout)
  arn = event.fetch("SecretId")
  token = event.fetch("ClientRequestToken")
  step = event.fetch("Step")

  # Setup the client
  service_client = Aws::SecretsManager::Client.new

  # Make sure the version is staged correctly
  metadata = service_client.describe_secret(secret_id: arn)

  unless metadata.rotation_enabled
    error = "Secret #{arn} is not enabled for rotation"
    logger.error(error)
    raise NotRotatable, error
  end

  versions = metadata.version_ids_to_stages

  unless versions.key?(token)
    error = "Secret version #{token} has no stage for rotation of secret #{arn}."
    logger.error(error)
    raise UnknownVersion, error
  end

  if versions[token].include?("AWSCURRENT")
    logger.info("Secret version #{token} already set as AWSCURRENT for secret #{arn}.")
    return
  end

  unless versions[token].include?("AWSPENDING")
    error = "Secret version #{token} not set as AWSPENDING for rotation of secret #{arn}."
    logger.error(error)
    raise NotPendingVersion, error
  end

  case step
  when "createSecret"
    create_secret(service_client, arn, token, logger)
  when "setSecret"
    check_secret(service_client, arn, token, logger)
  when "testSecret"
    test_secret(service_client, arn, token, logger)
  when "finishSecret"
    finish_secret(
      service_client,
      ENV.fetch("DEPLOY_EVENT_BUCKET"),
      arn,
      token,
      logger,
    )
  else
    raise ArgumentError, "Invalid step parameter"
  end
end

# Create the secret.
# This method first checks for the existence of a secret for the passed in
# token. If one does not exist, it will generate a new secret and put it with
# the passed in token.
def create_secret(service_client, arn, token, logger)
  # Retrieves the current SecretsManager secret resource. If no current version
  # exists we will exit.
  current_secret = service_client.get_secret_value(secret_id: arn, version_stage: "AWSCURRENT")

  # Now try to get the secret version, if that fails, put a new secret
  begin
    service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSPENDING")
    logger.info("createSecret: Successfully retrieved secret for #{arn}.")
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
    options = JSON.parse(current_secret.secret_string)
    api_user = options.fetch("api_user_email")
    application_name = options.fetch("application_name")
    deploy_event_key = options.fetch("deploy_event_key")
    permissions = options.fetch("permissions")

    signon_client = SignonClient.new(
      api_user: api_user,
      auth_token: get_admin_password(service_client, logger),
      logger: logger,
    )

    bearer_token = signon_client.create_bearer_token(
      application_name: application_name,
      permissions: permissions,
    )

    # Put the secret
    service_client.put_secret_value(
      secret_id: arn,
      client_request_token: token,
      secret_string: JSON.generate(
        api_user_email: api_user,
        application_name: application_name,
        deploy_event_key: deploy_event_key,
        permissions: permissions,
        bearer_token: bearer_token,
      ),
      version_stages: %w[AWSPENDING],
    )

    logger.info("createSecret: Successfully put secret for ARN #{arn} and version #{token}.")
  end
end

# Check the secret is in SecretsManager (in place of Lambda set step)
# This method checks that the newly created secret value is set as the
# AWSPENDING version in SecretsManager. Ordinarily, the Lambda would create
# the secret in the create step, and then set it in the 'identity service'
# (Signon). However, Signon creates the secret in the create step, so this step
# is a bit redundant.
def check_secret(service_client, arn, token, logger)
  service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSPENDING")
  logger.info("setSecret: Successfully retrieved secret for #{arn}.")
  logger.info("setSecret: The secret has already been set in signon")
end

# Test the secret
# Validates signon has the token and the correct permissions are set.
def test_secret(service_client, arn, token, logger)
  resp = service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSPENDING")
  secret = JSON.parse(resp.secret_string)
  application_name = secret.fetch("application_name")
  permissions = secret.fetch("permissions")

  signon_client = SignonClient.new(
    api_user: secret.fetch("api_user_email"),
    auth_token: get_admin_password(service_client, logger),
    logger: logger,
  )

  signon_client.test_bearer_token(
    token: secret.fetch("bearer_token"),
    application_name: application_name,
    permissions: permissions,
  )

  logger.info("testSecret SUCCESS! The secret is working!")
end

# Finish the secret
# This method finalizes the rotation process by marking the secret version
# passed in as the AWSCURRENT secret.
def finish_secret(service_client, s3_bucket, arn, token, logger)
  # First describe the secret to get the current version
  metadata = service_client.describe_secret(secret_id: arn)
  versions = metadata.version_ids_to_stages
  current_version = versions.keys.find do |version|
    versions[version].include?("AWSCURRENT")
  end

  if current_version == token
    # The correct version is already marked as current, return
    logger.info("finishSecret: Version #{token} already marked as AWSCURRENT for #{arn}")
    return
  end

  # Finalize by staging the secret version current
  service_client.update_secret_version_stage(
    secret_id: arn,
    version_stage: "AWSCURRENT",
    move_to_version_id: token,
    remove_from_version_id: current_version,
  )
  logger.info("finishSecret: Successfully set AWSCURRENT stage to version #{token} for secret #{arn}.")

  resp = service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSCURRENT")
  secret = JSON.parse(resp.secret_string)
  deploy_event_key = secret.fetch("deploy_event_key")

  s3 = Aws::S3::Client.new
  timestamp = Time.now.strftime("%Y-%m-%dT%H-%M-%S")
  filename = "#{deploy_event_key}/#{timestamp}-#{SecureRandom.hex(2)}.json"
  resp = s3.put_object({
    body: JSON.generate(
      reason: "Secret #{arn} was rotated by Lambda",
      timestamp: timestamp,
    ),
    bucket: s3_bucket,
    key: filename,
  })

  logger.info("finishSecret: Successfully wrote #{filename} to S3 bucket #{s3_bucket}/#{deploy_event_key}. Version ID: #{resp.version_id}")
end

def get_admin_password(service_client, _logger)
  secret = service_client.get_secret_value(
    secret_id: ENV.fetch("ADMIN_PASSWORD_KEY"),
    version_stage: "AWSCURRENT",
  )
  secret.secret_string
end
