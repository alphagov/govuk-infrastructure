require "json"
require_relative "../signon/bootstrap"

namespace :bootstrap do
  desc "Bootstrap bearer tokens for a Signon ApiUser"
  task :bearer_tokens do
    application = ENV["APPLICATION"]
    app_config = JSON.parse(File.read("../app-terraform-outputs/#{application}.json"))
    signon_secrets = app_config.dig(ENV["VARIANT"], "signon_secrets")
    secretsmanager = secretsmanager_client(
      "bootstrap-#{application}-bearer-tokens",
      ENV["ASSUME_ROLE_ARN"],
      ENV["AWS_REGION"],
    )
    signon = signon_client(
      secretsmanager,
      signon_secrets.dig("admin_password_arn"),
      signon_secrets.dig("signon_api_url"),
    )
    Signon::Bootstrap.bootstrap_tokens(
      app_config: signon_secrets,
      signon: signon,
      secretsmanager: secretsmanager,
    )
  end

  desc "Create Signon applications for an environment"
  task :oauth_applications do
    app_config = JSON.parse(File.read("../app-terraform-outputs/signon.json"))
    oauth_application_config = app_config.dig("oauth_application_config")
    secretsmanager = secretsmanager_client(
      "bootstrap-oauth-apps",
      ENV["ASSUME_ROLE_ARN"],
      ENV["AWS_REGION"],
    )
    signon = signon_client(
      secretsmanager,
      oauth_application_config.dig("admin_password_arn"),
      oauth_application_config.dig("signon_api_url"),
    )
    Signon::Bootstrap.bootstrap_applications(
      applications: oauth_application_config.dig("applications"),
      signon: signon,
      secretsmanager: secretsmanager,
    )
  end
end

def signon_client(secretsmanager, api_token_arn, api_url)
  admin_secret = secretsmanager.get_secret_value(
    secret_id: api_token_arn,
    version_stage: "AWSCURRENT",
  )
  Signon::Client.new(
    api_url: api_url,
    auth_token: admin_secret.secret_string,
    max_retries: 10,
  )
end

def secretsmanager_client(session_name, role_arn, region)
  credentials = Aws::AssumeRoleCredentials.new(
    client: Aws::STS::Client.new,
    role_arn: role_arn,
    role_session_name: session_name,
  )

  Aws::SecretsManager::Client.new(
    region: region,
    credentials: credentials,
  )
end
