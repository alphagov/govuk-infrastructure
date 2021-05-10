require "aws-sdk-secretsmanager"
require "logger"
require_relative "./client"

module Signon
  module Bootstrap
    class NotRotatable < StandardError; end

    def self.bootstrap_applications(applications:, signon:, secretsmanager:, logger: Logger.new($stdout))
      applications.each do |app|
        bootstrap_application(
          app: app,
          secretsmanager: secretsmanager,
          signon: signon,
          logger: logger,
        )
      end
    end

    def self.bootstrap_application(app:, secretsmanager:, signon:, logger:)
      app_name = app.dig("name")
      oauth_id_arn = app.dig("id_arn")
      oauth_secret_arn = app.dig("secret_arn")

      bootstrap_required = [oauth_id_arn, oauth_secret_arn].any? do |arn|
        should_bootstrap(secretsmanager, arn)
      end

      unless bootstrap_required
        logger.info "Secrets for #{app_name} already bootstrapped. Bailing out."
        return
      end

      logger.info "Secret (#{app_name}) doesn't have secret values in SecretsManager. Creating them..."
      secrets = find_or_create_app(signon, app)

      logger.info "Application #{app_name} created or fetched. Putting creds in SecretsManager..."
      secretsmanager.put_secret_value(
        secret_id: oauth_id_arn,
        secret_string: secrets.dig("oauth_id"),
        version_stages: %w[AWSCURRENT],
      )
      secretsmanager.put_secret_value(
        secret_id: oauth_secret_arn,
        secret_string: secrets.dig("oauth_secret"),
        version_stages: %w[AWSCURRENT],
      )
      logger.info "App (#{app_name}) bootstrapping finished."
    end

    def self.find_or_create_app(signon_client, app)
      signon_client.create_application(
        name: app.dig("name"),
        description: app.dig("description"),
        home_uri: app.dig("home_uri"),
        permissions: app.dig("permissions"),
        redirect_uri: app.dig("redirect_uri"),
      )
    rescue Signon::Client::ApplicationAlreadyCreated
      signon_client.get_application(name: app.dig("name"))
    end

    def self.should_bootstrap(secretsmanager, secret_arn)
      metadata = secretsmanager.describe_secret(secret_id: secret_arn)
      versions = metadata.version_ids_to_stages
      versions.nil? || versions.values.none? { |stages| stages.include?("AWSCURRENT") }
    end

    def self.bootstrap_tokens(app_config:, signon:, secretsmanager:, logger: Logger.new($stdout))
      app_config.dig("bearer_tokens").each do |token|
        bootstrap_bearer_token(
          api_user: app_config.dig("api_user_email"),
          token: token,
          secrets_client: secretsmanager,
          signon_client: signon,
          logger: logger,
        )
      end
    end

    def self.bootstrap_bearer_token(api_user:, token:, secrets_client:, signon_client:, logger: Logger.new($stdout))
      secret_arn = token.dig("secret_arn")
      metadata = secrets_client.describe_secret(secret_id: secret_arn)
      unless metadata.rotation_enabled
        raise NotRotatable, "Secret #{secret_arn} is not enabled for rotation"
      end

      versions = metadata.version_ids_to_stages
      has_current_version = versions.values.any? { |stages| stages.include?("AWSCURRENT") }
      if has_current_version
        logger.info "Secret #{secret_arn} already bootstrapped."
        return
      end

      logger.info "Secret #{secret_arn} doesn't have a secret value. Creating it..."
      secret_string = signon_client.create_bearer_token(
        api_user: api_user,
        application_name: token.dig("application"),
        permissions: token.dig("permissions").split(","),
      )

      logger.info "Secret #{secret_arn} created. Putting value in SecretsManager..."
      secrets_client.put_secret_value(
        secret_id: secret_arn,
        secret_string: secret_string,
        version_stages: %w[AWSCURRENT],
      )
      logger.info "Secret #{secret_arn} finished."
    end
  end
end
