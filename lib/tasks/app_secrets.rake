require "json"
require_relative "../signon/bootstrap"

namespace :app_secrets do
  desc "Bootstrap secrets for Signon"
  task :bootstrap do
    application = ENV["APPLICATION"]
    app_config = JSON.parse(File.read("../app-terraform-outputs/#{application}.json"))
    signon_secrets = app_config.dig(ENV["VARIANT"], "signon_secrets")

    Signon::Bootstrap.bootstrap_secrets(
      app_config: signon_secrets,
      aws: {
        "credentials" => role_credentials(application, ENV["ASSUME_ROLE_ARN"]),
        "region" => ENV["AWS_REGION"],
      },
    )
  end
end

def role_credentials(application, role_arn)
  Aws::AssumeRoleCredentials.new(
    client: Aws::STS::Client.new,
    role_arn: role_arn,
    role_session_name: "bootstrap-#{application}-bearer-tokens",
  )
end
