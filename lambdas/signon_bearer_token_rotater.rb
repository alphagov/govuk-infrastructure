require "aws-sdk-secretsmanager"
require "json"
require "logger"
require "net/http"
require "uri"

class SignonClient
  ENDPOINT = ENV.fetch("SIGNON_API_URL")

  def initialize(api_user:, auth_token:)
    @api_user = api_user
    @auth_token = auth_token
  end

  def create_bearer_token(application_name:, permissions:)
    uri = URI("#{ENDPOINT}/authorisations")
    req = Net::HTTP::Post.new(uri)
    req.body = {
      api_user_email: @api_user,
      application_name: application_name,
      permissions: permissions
    }.to_json
    res = do_request(req, uri)
    raise TokenNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless %w[200 201].include?(res.code)

    JSON.parse(res.body).fetch('token')
  end

  def test_bearer_token(token:, application_name:, permissions:)
    uri = URI("#{ENDPOINT}/authorisations/test")
    req = Net::HTTP::Post.new(uri)
    req.body = {
      token: token,
      api_user_email: @api_user,
      application_name: application_name,
      permissions: permissions
    }.to_json
    res = do_request(req, uri)
    raise TokenNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == '200'
  end

private

  class TokenNotFound < StandardError; end

  class TokenNotCreated < StandardError; end

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

  signon_client = SignonClient.new(
    api_user: ENV.fetch("API_USER_EMAIL"),
    auth_token: get_admin_password(service_client, logger),
    logger: logger,
  )

  case step
  when "createSecret"
    create_secret(service_client, arn, token, logger, signon_client)
  when "setSecret"
    check_secret(service_client, arn, token, logger)
  when "testSecret"
    test_secret(service_client, arn, token, logger, signon_client)
  when "finishSecret"
    finish_secret(service_client, arn, token, logger)
  else
    raise ArgumentError, "Invalid step parameter"
  end
end

# Create the secret.
# This method first checks for the existence of a secret for the passed in
# token. If one does not exist, it will generate a new secret and put it with
# the passed in token.
def create_secret(service_client, arn, token, logger, signon_client)
  # Check if the current SecretsManager secret resource exists. If there's
  # no current secret we'll create a new one.
  service_client.get_secret_value(secret_id: arn, version_stage: "AWSCURRENT")

  # Now try to get the secret version, if that fails, put a new secret
  service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSPENDING")
  logger.info("createSecret: Successfully retrieved secret for #{arn}.")
rescue Aws::SecretsManager::Errors::ResourceNotFoundException
  secret_string = signon_client.create_bearer_token(
    application_name: ENV.fetch("APPLICATION_NAME"),
    permissions: ENV.fetch("PERMISSIONS").split(","),
  )

  # Put the secret
  service_client.put_secret_value(
    secret_id: arn,
    client_request_token: token,
    secret_string: secret_string,
    version_stages: %w[AWSPENDING],
  )

  logger.info("createSecret: Successfully put secret for ARN #{arn} and version #{token}.")
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
def test_secret(service_client, arn, token, logger, signon_client)
  secret = service_client.get_secret_value(secret_id: arn, version_id: token, version_stage: "AWSPENDING")

  signon_client.test_bearer_token(
    token: secret.secret_string,
    application_name: ENV.fetch("APPLICATION_NAME"),
    permissions: ENV.fetch("PERMISSIONS"),
  )

  logger.info("[wip] testSecret SUCCESS! The secret is working!")
end

# Finish the secret
# This method finalizes the rotation process by marking the secret version
# passed in as the AWSCURRENT secret.
def finish_secret(service_client, arn, token, logger)
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
end

def get_admin_password(service_client, _logger)
  secret = service_client.get_secret_value(
    secret_id: ENV.fetch("ADMIN_PASSWORD_KEY"),
    version_stage: "AWSCURRENT",
  )
  secret.secret_string
end
