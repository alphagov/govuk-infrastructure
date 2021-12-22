require "logger"
require_relative "./client"

module Signon
  module Bootstrap
    class NotRotatable < StandardError; end

    def self.create_applications(applications:, signon:, kubernetes:)
      applications.each_with_object({}) do |(app_slug, app_data), obj|
        application = begin
          signon.create_application(
            name: app_data["name"],
            description: app_data["description"],
            home_uri: app_data["home_uri"],
            permissions: app_data["permissions"],
            redirect_uri: app_data["redirect_uri"],
          )
        rescue Signon::Client::ApplicationAlreadyCreated
          signon.get_application(name: app_data["name"])
        end
        kubernetes.put_secret_value(
          secret_name: "signon-app-#{app_slug}",
          secret_data: application,
        )
        obj[app_slug] = application.fetch("id")
      end
    end

    def self.create_api_users(api_users:, signon:)
      api_users.each_with_object({}) do |(slug, api_user), obj|
        response = begin
          signon.create_api_user(
            name: api_user["name"],
            email: api_user["email"],
          )
        rescue Signon::Client::ApiUserAlreadyCreated
          signon.get_api_user(email: api_user["email"])
        end

        obj[slug] = response["id"]
      end
    end

    def self.create_bearer_tokens(bearer_tokens:, signon:, kubernetes:)
      bearer_tokens.each do |token|
        next if kubernetes.secret_exists?(secret_name: token[:name])

        response = signon.create_bearer_token(
          api_user_id: token[:api_user_id],
          application_id: token[:application_id],
          permissions: token[:permissions],
        )

        kubernetes.put_secret_value(
          secret_name: token[:name],
          secret_data: { bearer_token: response.fetch("token") },
        )
      end
      nil
    end
  end
end
