require "spec_helper"

RSpec.describe "rake bootstrap:signon" do
  subject(:bootstrap_task) do
    bootstrap_signon
  end

  let(:kubernetes_client) do
    double(Kubernetes::Client)
  end

  let(:signon_client) do
    double(Signon::Client)
  end

  let(:api_users) do
    Factories::Signon.api_users
  end

  let(:applications) do
    Factories::Signon.applications
  end

  let(:signon_applications) do
    {
      "content-store" => "content-store-app-id",
      "frontend" => "frontend-app-id",
      "publishing-api" => "publishing-api-app-id",
    }
  end

  let(:signon_api_users) do
    {
      "content-store" => "content-store-user-id",
      "frontend" => "frontend-user-id",
      "publishing-api" => "publishing-api-user-id",
    }
  end

  let(:parsed_bearer_tokens) do
    [
      {
        api_user_id: "content-store-user-id",
        application_id: "publishing-api-app-id",
        name: "signon-token-content-store-publishing-api",
        permissions: [],
      },
      {
        api_user_id: "frontend-user-id",
        application_id: "content-store-app-id",
        name: "signon-token-frontend-content-store",
        permissions: %w[internal_app],
      },
      {
        api_user_id: "frontend-user-id",
        application_id: "publishing-api-app-id",
        name: "signon-token-frontend-publishing-api",
        permissions: [],
      },
    ]
  end

  before do
    allow(Kubernetes::ClientFactory).to receive(:create).and_return(kubernetes_client)
  end

  context "when env vars are missing" do
    it "raises an argument error" do
      expect { bootstrap_task }.to raise_error(KeyError)
    end
  end

  context "when env vars are empty" do
    it "passes" do
      with_modified_env APPLICATIONS: "[]", API_USERS: "[]", SIGNON_API_ENDPOINT: "", SIGNON_AUTH_TOKEN: "" do
        expect { bootstrap_task }.not_to raise_error
      end
    end
  end

  it "creates signon resources" do
    with_modified_env APPLICATIONS: JSON.generate(applications),
                      API_USERS: JSON.generate(api_users),
                      SIGNON_API_ENDPOINT: "https://signon.example.gov.uk",
                      SIGNON_AUTH_TOKEN: "signon-auth-token" do
      allow(Signon::Client).to receive(:new)
        .with(api_url: "https://signon.example.gov.uk", auth_token: "signon-auth-token", max_retries: 10)
        .and_return(signon_client)
      allow(Signon::Bootstrap).to receive(:create_applications)
        .with(applications: applications, signon: signon_client, kubernetes: kubernetes_client)
        .and_return(signon_applications)
      allow(Signon::Bootstrap).to receive(:create_api_users)
        .with(api_users: api_users, signon: signon_client)
        .and_return(signon_api_users)
      allow(Signon::Bootstrap).to receive(:create_bearer_tokens)
        .with(bearer_tokens: parsed_bearer_tokens, signon: signon_client, kubernetes: kubernetes_client)
        .and_return(nil)

      bootstrap_task
    end
  end

  context "when application has not been created" do
    let(:api_users) do
      {
        "frontend" => {
          "name" => "Frontend",
          "username" => "frontend",
          "email" => "frontend@test.publishing.service.gov.uk",
          "bearer_tokens" => [
            { "application_slug" => "non-existent-application" },
          ],
        },
      }
    end

    it "raises an alert" do
      with_modified_env APPLICATIONS: JSON.generate(applications),
                        API_USERS: JSON.generate(api_users),
                        SIGNON_API_ENDPOINT: "https://signon.example.gov.uk",
                        SIGNON_AUTH_TOKEN: "signon-auth-token" do
        allow(Signon::Client).to receive(:new)
          .with(api_url: "https://signon.example.gov.uk", auth_token: "signon-auth-token", max_retries: 10)
          .and_return(signon_client)
        allow(Signon::Bootstrap).to receive(:create_applications)
          .with(applications: applications, signon: signon_client, kubernetes: kubernetes_client)
          .and_return(signon_applications)
        allow(Signon::Bootstrap).to receive(:create_api_users)
          .with(api_users: api_users, signon: signon_client)
          .and_return(signon_api_users)
        expect { bootstrap_task }.to raise_error(
          /Unknown application: non-existent-application for api_user frontend./,
        )
      end
    end
  end
end
