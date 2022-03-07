require "logger"
require_relative "./client"

module Signon
  module Bootstrap
    class NotRotatable < StandardError; end

    def self.sync_application(signon:, kubernetes:, app_data:)
      application = begin
        signon.create_application(
          name: app_data["name"],
          description: app_data["description"],
          home_uri: app_data["home_uri"],
          permissions: app_data["permissions"],
          redirect_uri: app_data["redirect_uri"],
        )
      rescue Signon::Client::ApplicationAlreadyCreated
        existing_app = signon.get_application(name: app_data["name"])

        same_config = existing_app["name"] == app_data["name"] &&
          existing_app["description"] == app_data["description"] &&
          existing_app["permissions"].sort == app_data["permissions"].sort

        if same_config
          existing_app
        else
          signon.update_application(
            id: existing_app["id"],
            name: app_data["name"],
            description: app_data["description"],
            permissions: app_data["permissions"],
          )
        end
      end

      kubernetes.put_secret_value(
        secret_name: app_data.fetch("secret_name"),
        secret_data: application,
      )

      application
    end

    def self.sync_applications(applications:, signon:, kubernetes:)
      applications.each_with_object({}) do |(app_slug, app_data), obj|
        application = sync_application(
          signon: signon,
          kubernetes: kubernetes,
          app_data: app_data,
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
