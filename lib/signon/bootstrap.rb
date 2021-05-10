require "aws-sdk-secretsmanager"
require "logger"
require_relative "./client"

module Signon
  module Bootstrap
    class NotRotatable < StandardError; end

    def self.bootstrap_secrets(app_config:, aws:)
      logger = Logger.new($stdout)
      secrets_client = Aws::SecretsManager::Client.new(
        region: aws.dig("region"),
        credentials: aws.dig("credentials"),
      )
      admin_secret = secrets_client.get_secret_value(
        secret_id: app_config.dig("admin_password_arn"),
        version_stage: "AWSCURRENT",
      )
      signon_client = Signon::Client.new(
        api_user: app_config.dig("api_user_email"),
        api_url: app_config.dig("signon_api_url"),
        auth_token: admin_secret.secret_string,
        logger: logger,
      )
      app_config.dig("bearer_tokens").each do |token|
        bootstrap_bearer_token(
          token_data: token,
          secrets_client: secrets_client,
          signon_client: signon_client,
          logger: logger,
        )
      end
    end

    def self.bootstrap_bearer_token(token_data:, secrets_client:, signon_client:, logger: Logger.new($stdout))
      secret_arn = token_data.dig("secret_arn")
      metadata = secrets_client.describe_secret(secret_id: secret_arn)
      unless metadata.rotation_enabled
        raise NotRotatable, "Secret #{secret_arn} is not enabled for rotation"
      end

      versions = metadata.version_ids_to_stages
      if versions.any?
        logger.info "Secret #{secret_arn} already bootstrapped."
        return
      end

      logger.info "Secret #{secret_arn} doesn't have a secret value. Creating it..."
      secret_string = signon_client.create_bearer_token(
        application_name: token_data.dig("application"),
        permissions: token_data.dig("permissions").split(","),
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
