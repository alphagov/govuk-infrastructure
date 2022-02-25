require "json"
require_relative "../signon/bootstrap"
require_relative "../signon/client"
require_relative "../kubernetes/client"
require_relative "../kubernetes/client_factory"

namespace :bootstrap do
  desc "Bootstrap Signon resources in a Kubernetes cluster"
  task :signon do
    bootstrap_signon
  end
end

def bootstrap_signon
  applications = JSON.parse(ENV.fetch("APPLICATIONS"))
  api_users = JSON.parse(ENV.fetch("API_USERS"))

  signon = Signon::Client.new(
    api_url: ENV.fetch("SIGNON_API_ENDPOINT"),
    auth_token: ENV.fetch("SIGNON_AUTH_TOKEN"),
    max_retries: 10,
  )

  kubernetes = Kubernetes::ClientFactory.create({
    control_plane_uri: ENV.fetch("KUBERNETES_CONTROL_PLANE_URI", "https://kubernetes.default.svc"),
    version: ENV.fetch("KUBERNETES_API_VERSION", "v1"),
  })

  signon_apps = Signon::Bootstrap.create_applications(
    applications: applications,
    signon: signon,
    kubernetes: kubernetes,
  )

  signon_users = Signon::Bootstrap.create_api_users(
    api_users: api_users,
    signon: signon,
  )

  bearer_tokens = api_users.map { |username, data|
    data.fetch("bearer_tokens", []).map do |token|
      app_slug = token["application_slug"]
      app_id = signon_apps[app_slug]

      unless app_id
        raise ArgumentError, "
          Unknown application: #{app_slug} for api_user #{username}.\n
          Did you create the #{app_slug} application?"
      end

      {
        name: "signon-token-#{username}-#{token['application_slug']}",
        permissions: token.fetch("permissions", []),
        api_user_id: signon_users[username],
        application_id: app_id,
      }
    end
  }.flatten

  Signon::Bootstrap.create_bearer_tokens(
    bearer_tokens: bearer_tokens,
    signon: signon,
    kubernetes: kubernetes,
  )

  puts JSON.generate({
    applications: signon_apps.keys,
    api_users: api_users.map { |name, _| name },
    bearer_tokens: bearer_tokens.map { |token| token[:name] },
  })
end
