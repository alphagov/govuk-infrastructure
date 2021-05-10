require "signon/bootstrap"

RSpec.describe Signon::Bootstrap do
  subject(:call) do
    described_class.bootstrap_secrets(
      app_config: {
        "admin_password_arn" => password,
        "api_user_email" => api_user,
        "signon_api_url" => "https://signon.example.org",
        "bearer_tokens" => [
          {
            "secret_arn" => arn,
            "application" => app_name,
            "permissions" => permissions,
          },
        ],
      },
      aws: {
        "region" => "eu-west-1",
        "credentials" => credentials,
      },
    )
  end

  let(:arn) { "arn:secretsmanager:123" }
  let(:versions) do
    { "version" => %w[AWSPENDING] }
  end
  let(:metadata) do
    double(
      rotation_enabled: true,
      version_ids_to_stages: versions,
    )
  end
  let(:password) { "password" }
  let(:api_user) { "publisher@example.org" }
  let(:admin_password) do
    double(secret_string: "secret")
  end
  let(:app_name) { "publishing-api" }
  let(:permissions) { "signin" }
  let(:generated_secret) { "hunter2" }
  let(:credentials) do
    instance_double(Aws::AssumeRoleCredentials)
  end

  before do
    allow_any_instance_of(Aws::SecretsManager::Client).to \
      receive(:describe_secret)
      .with(secret_id: arn)
      .and_return(metadata)

    stub_get_secret
      .with(secret_id: password, version_stage: "AWSCURRENT")
      .and_return(admin_password)
  end

  context "when secret rotation is disabled" do
    let(:metadata) { double(rotation_enabled: false) }

    it "raises an error" do
      expect { call }.to raise_error Signon::Bootstrap::NotRotatable
    end
  end

  context "when secret has already been created" do
    let(:versions) { { "version1" => %w[AWSCURRENT] } }

    it "does not create a new token" do
      signon_request = stub_request(:post, /signon.example.org/)

      expect { call }.not_to raise_error
      expect(signon_request).not_to have_been_requested
    end
  end

  context "when no AWSCURRENT secret version exist yet" do
    let(:versions) { { "version1" => %w[AWSPENDING] } }

    it "creates a secret in signon" do
      stub = stub_request(:post, /signon.example.org/)
             .with(
               body: JSON.generate(
                 api_user_email: api_user,
                 application_name: app_name,
                 permissions: [permissions],
               ),
             )
             .to_return(
               status: 200,
               body: JSON.generate(token: generated_secret),
             )

      allow_any_instance_of(Aws::SecretsManager::Client).to \
        receive(:put_secret_value)
        .with(
          secret_id: arn,
          secret_string: generated_secret,
          version_stages: %w[AWSCURRENT],
        )

      expect { call }.not_to raise_error
      expect(stub).to have_been_requested
    end
  end

  def stub_get_secret
    allow_any_instance_of(Aws::SecretsManager::Client).to \
      receive(:get_secret_value)
  end
end
