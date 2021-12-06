require "signon/bootstrap"
require "kubernetes/client"

RSpec.describe Signon::Bootstrap do
  let(:signon_client) do
    instance_double(Signon::Client)
  end

  let(:kubernetes_client) do
    instance_double(Kubernetes::Client)
  end

  let(:applications) do
    Factories::Signon.applications
  end

  let(:signon_apps) do
    {
      "content-store" => { "id" => "content-store-id", "oauth_id" => "123", "oauth_secret" => "456" },
      "publishing-api" => { "id" => "pub-api-id", "oauth_id" => "456", "oauth_secret" => "789" },
    }
  end

  let(:api_users) do
    Factories::Signon.api_users
  end

  let(:bearer_tokens) do
    [
      {
        name: "signon-token-content-store-publishing-api",
        permissions: [],
        application_id: "content-store-user-id",
        api_user_id: "publishing-api-id",
      },
      {
        name: "signon-token-frontend-content-store",
        permissions: %w[special-access],
        application_id: "frontend-user-id",
        api_user_id: "content-store-id",
      },
      {
        name: "signon-token-frontend-publishing-api",
        permissions: [],
        application_id: "frontend-user-id",
        api_user_id: "publishing-api-id",
      },
    ]
  end

  let(:generated_tokens) do
    bearer_tokens.each_with_object({}) do |token, obj|
      obj[token[:name]] = SecureRandom.hex(3)
    end
  end

  describe "#create_applications" do
    subject(:create_signon_apps) do
      described_class.create_applications(
        applications: applications,
        signon: signon_client,
        kubernetes: kubernetes_client,
      )
    end

    it "creates the applications and stores their creds in Secrets" do
      applications.each do |app_slug, app|
        allow(signon_client).to receive(:create_application)
          .with(
            name: app["name"],
            description: app["description"],
            home_uri: app["home_uri"],
            permissions: app["permissions"],
            redirect_uri: app["redirect_uri"],
          )
          .and_return(signon_apps[app_slug])

        allow(kubernetes_client).to receive(:put_secret_value)
          .with(
            secret_name: "signon-app-#{app_slug}",
            secret_data: signon_apps[app_slug],
          )
      end

      expect(create_signon_apps).to eq({ "content-store" => "content-store-id", "publishing-api" => "pub-api-id" })
    end

    describe "is idempotent" do
      context "when one application already created" do
        it "creates only new applications" do
          pub_app = applications["publishing-api"]
          allow(signon_client).to receive(:create_application)
            .with(
              name: pub_app["name"],
              description: pub_app["description"],
              home_uri: pub_app["home_uri"],
              permissions: pub_app["permissions"],
              redirect_uri: pub_app["redirect_uri"],
            )
            .and_raise(Signon::Client::ApplicationAlreadyCreated)

          allow(signon_client).to receive(:get_application)
            .with(name: pub_app["name"])
            .and_return(signon_apps["publishing-api"])

          content_app = applications["content-store"]
          allow(signon_client).to receive(:create_application)
            .with(
              name: content_app["name"],
              description: content_app["description"],
              home_uri: content_app["home_uri"],
              permissions: content_app["permissions"],
              redirect_uri: content_app["redirect_uri"],
            )
            .and_return(signon_apps["content-store"])

          allow(kubernetes_client).to receive(:put_secret_value)
            .with(
              secret_name: "signon-app-publishing-api",
              secret_data: signon_apps["publishing-api"],
            )

          allow(kubernetes_client).to receive(:put_secret_value)
            .with(
              secret_name: "signon-app-content-store",
              secret_data: signon_apps["content-store"],
            )

          expect(create_signon_apps).to eq({ "content-store" => "content-store-id", "publishing-api" => "pub-api-id" })
        end
      end
    end
  end

  describe "#create_api_users" do
    subject(:signon_api_users) do
      described_class.create_api_users(
        api_users: api_users,
        signon: signon_client,
      )
    end

    it "creates the api users" do
      api_users.each do |slug, api_user|
        allow(signon_client).to receive(:create_api_user)
          .with(name: api_user["name"], email: api_user["email"])
          .and_return({ "id" => "#{slug}-user-id" })
      end

      expect(signon_api_users).to eq({
        "content-store" => "content-store-user-id",
        "frontend" => "frontend-user-id",
      })
    end

    describe "is idempotent" do
      context "when an api user already exists" do
        it "creates only new api users" do
          frontend = api_users["frontend"]
          content_store = api_users["content-store"]

          allow(signon_client).to receive(:create_api_user)
            .with(name: frontend["name"], email: frontend["email"])
            .and_return({ "id" => "frontend-user-id" })

          allow(signon_client).to receive(:create_api_user)
            .with(name: content_store["name"], email: content_store["email"])
            .and_raise(Signon::Client::ApiUserAlreadyCreated)

          allow(signon_client).to receive(:get_api_user)
            .with(email: content_store["email"])
            .and_return({ "id" => "content-store-user-id" })

          expect(signon_api_users).to eq({
            "content-store" => "content-store-user-id",
            "frontend" => "frontend-user-id",
          })
        end
      end
    end
  end

  describe "#create_bearer_tokens" do
    subject(:signon_bearer_tokens) do
      described_class.create_bearer_tokens(
        bearer_tokens: bearer_tokens,
        signon: signon_client,
        kubernetes: kubernetes_client,
      )
    end

    it "creates bearer tokens" do
      bearer_tokens.each do |token|
        allow(kubernetes_client).to receive(:secret_exists?)
          .with({ secret_name: token[:name] })
          .and_return(false)

        allow(signon_client).to receive(:create_bearer_token)
          .with({ api_user_id: token[:api_user_id], application_id: token[:application_id], permissions: token[:permissions] })
          .and_return({ "token" => generated_tokens[token[:name]] })

        allow(kubernetes_client).to receive(:put_secret_value)
          .with({
            secret_name: token[:name],
            secret_data: {
              bearer_token: generated_tokens[token[:name]],
            },
          })
      end

      expect(signon_bearer_tokens).to eq(nil)
    end

    describe "is idempotent" do
      context "when a bearer token already exists" do
        it "creates only new bearer tokens" do
          new_token = bearer_tokens.first
          existing_tokens = bearer_tokens[1..]

          allow(kubernetes_client).to receive(:secret_exists?)
            .with({ secret_name: new_token[:name] })
            .and_return(true)

          existing_tokens.each do |token|
            allow(kubernetes_client).to receive(:secret_exists?)
              .with({ secret_name: token[:name] })
              .and_return(false)

            allow(signon_client).to receive(:create_bearer_token)
              .with({ api_user_id: token[:api_user_id], application_id: token[:application_id], permissions: token[:permissions] })
              .and_return({ "token" => generated_tokens[token[:name]] })

            allow(kubernetes_client).to receive(:put_secret_value)
              .with({
                secret_name: token[:name],
                secret_data: {
                  bearer_token: generated_tokens[token[:name]],
                },
              })
          end

          expect(signon_bearer_tokens).to eq(nil)
        end
      end
    end
  end
end
