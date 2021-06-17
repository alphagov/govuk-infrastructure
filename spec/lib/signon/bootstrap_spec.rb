require "signon/bootstrap"

RSpec.describe Signon::Bootstrap do
  let(:versions) do
    { "version" => %w[AWSPENDING] }
  end
  let(:metadata) do
    double(
      rotation_enabled: true,
      version_ids_to_stages: versions,
    )
  end
  let(:admin_password_arn) { "admin_password_arn" }
  let(:admin_password) do
    double(secret_string: "secret")
  end
  let(:secretsmanager_client) do
    instance_double(Aws::SecretsManager::Client)
  end

  let(:signon_client) do
    instance_double(Signon::Client)
  end

  def expect_token_secret_describe_call
    expect(secretsmanager_client).to receive(:describe_secret)
      .with(secret_id: token_arn)
      .and_return(metadata)
  end

  describe "#bootstrap_tokens" do
    subject(:call) do
      logger = Logger.new($stdout)
      logger.level = Logger::WARN
      described_class.bootstrap_tokens(
        app_config: {
          "api_user_email" => api_user,
          "deploy_event_key" => app_name,
          "bearer_tokens" => [
            {
              "secret_arn" => token_arn,
              "application" => app_name,
              "permissions" => permissions,
            },
          ],
        },
        signon: signon_client,
        secretsmanager: secretsmanager_client,
        logger: logger,
      )
    end

    let(:api_user) { "publisher@example.org" }
    let(:token_arn) { "arn:secretsmanager:123" }
    let(:app_name) { "publishing-api" }
    let(:permissions) { "signin" }
    let(:generated_secret) { "hunter2" }

    context "when secret rotation is disabled" do
      let(:metadata) { double(rotation_enabled: false) }

      it "raises an error" do
        expect_token_secret_describe_call
        expect { call }.to raise_error Signon::Bootstrap::NotRotatable
      end
    end

    context "when secret has already been created" do
      let(:versions) { { "version1" => %w[AWSCURRENT] } }

      it "does not create a new token" do
        expect_token_secret_describe_call
        expect(signon_client).not_to receive(:create_bearer_token)
        expect { call }.not_to raise_error
      end
    end

    context "when no AWSCURRENT secret version exist yet" do
      let(:versions) { { "version1" => %w[AWSPENDING] } }

      it "creates a secret in signon" do
        expect_token_secret_describe_call
        expect(signon_client).to receive(:create_bearer_token)
          .with(
            api_user: api_user,
            application_name: app_name,
            permissions: [permissions],
          )
          .and_return(generated_secret)

        expect(secretsmanager_client).to receive(:put_secret_value)
          .with(
            secret_id: token_arn,
            secret_string: JSON.generate(
              api_user_email: api_user,
              application_name: app_name,
              deploy_event_key: app_name,
              permissions: [permissions],
              bearer_token: generated_secret,
            ),
            version_stages: %w[AWSCURRENT],
          )

        expect { call }.not_to raise_error
      end
    end
  end

  describe "#bootstrap_applications" do
    subject(:call) do
      logger = Logger.new($stdout)
      logger.level = Logger::WARN
      described_class.bootstrap_applications(
        applications: [
          {
            "name" => name,
            "id_arn" => id_arn,
            "secret_arn" => secret_arn,
            "permissions" => permissions,
            "description" => description,
            "home_uri" => home_uri,
            "redirect_uri" => redirect_uri,
          },
        ],
        signon: signon_client,
        secretsmanager: secretsmanager_client,
        logger: logger,
      )
    end

    let(:name) { "Publishing API" }
    let(:id_arn) { "arn:id:123" }
    let(:secret_arn) { "arn:secret:123" }
    let(:permissions) { %w[signin] }
    let(:description) { "Content Management System backend" }
    let(:home_uri) { "https://pub-api.example.org" }
    let(:redirect_uri) { "https://pub-api.example.org/redirect" }
    let(:oauth_id) { "oauth_id" }
    let(:oauth_secret) { "oauth_secret" }

    context "when the application has not been created" do
      let(:versions) do
        {}
      end

      it "will create the application and put the secret in SecretsManager" do
        expect(secretsmanager_client).to receive(:describe_secret)
          .with(secret_id: id_arn)
          .and_return(metadata)

        expect(signon_client).to receive(:create_application)
          .with(
            name: name,
            description: description,
            home_uri: home_uri,
            permissions: permissions,
            redirect_uri: redirect_uri,
          )
          .and_return({ "oauth_id" => oauth_id, "oauth_secret" => oauth_secret })

        expect(secretsmanager_client).to receive(:put_secret_value)
          .with(
            secret_id: secret_arn,
            secret_string: oauth_secret,
            version_stages: %w[AWSCURRENT],
          )

        expect(secretsmanager_client).to receive(:put_secret_value)
          .with(
            secret_id: id_arn,
            secret_string: oauth_id,
            version_stages: %w[AWSCURRENT],
          )

        expect { call }.not_to raise_error
      end
    end

    context "when application has been created" do
      context "when credentials are in secretsmanager" do
        let(:versions) do
          { "version1" => %w[AWSCURRENT] }
        end

        it "will verify the credentials have been set in SecretsManager and not create a new application or secret" do
          expect(secretsmanager_client).to receive(:describe_secret)
            .with(secret_id: secret_arn)
            .and_return(metadata)

          expect(secretsmanager_client).to receive(:describe_secret)
            .with(secret_id: id_arn)
            .and_return(metadata)

          expect(signon_client).not_to receive(:create_application)
          expect(secretsmanager_client).not_to receive(:put_secret_value)

          expect { call }.not_to raise_error
        end
      end

      context "when credentials are not in secretsmanager" do
        let(:versions) do
          nil # versions can be nil when there are no versions.
        end

        it "will retrieve the credentials from Signon and set them in SecretsManager" do
          expect(secretsmanager_client).to receive(:describe_secret)
            .with(secret_id: id_arn)
            .and_return(metadata)

          expect(signon_client).to receive(:create_application)
            .with(
              name: name,
              description: description,
              home_uri: home_uri,
              permissions: permissions,
              redirect_uri: redirect_uri,
            )
            .and_raise(Signon::Client::ApplicationAlreadyCreated)

          expect(signon_client).to receive(:get_application)
            .with(name: name)
            .and_return({ "oauth_id" => oauth_id, "oauth_secret" => oauth_secret })

          expect(secretsmanager_client).to receive(:put_secret_value)
            .with(
              secret_id: secret_arn,
              secret_string: oauth_secret,
              version_stages: %w[AWSCURRENT],
            )

          expect(secretsmanager_client).to receive(:put_secret_value)
            .with(
              secret_id: id_arn,
              secret_string: oauth_id,
              version_stages: %w[AWSCURRENT],
            )

          expect { call }.not_to raise_error
        end
      end
    end
  end
end
