# frozen_string_literal: true

ENV['SIGNON_API_URL'] = 'https://signon.example.org'
ENV['AWS_ACCESS_KEY_ID'] = "stub"
ENV['AWS_SECRET_ACCESS_KEY'] = "stub"
ENV['AWS_REGION'] = "stub"

require_relative '../../lambdas/signon_bearer_token_rotater'

RSpec.describe SignonClient do
  let(:api_user) { 'publisher@example.org' }
  let(:auth_token) { 'hunter2' }
  let(:application_name) { 'publishing-api' }
  let(:permissions) { 'signin,publish' }

  let(:client) do
    described_class.new(api_user: api_user, auth_token: auth_token)
  end

  describe '#create_bearer_token' do
    let(:endpoint) { "#{ENV['SIGNON_API_URL']}/authorisations" }
    subject(:response) do
      client.create_bearer_token(
        application_name: application_name,
        permissions: permissions
      )
    end

    context 'signon request is successful' do
      it 'creates a bearer token' do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(token: auth_token)
        )
        expect(response).to eq(auth_token)
      end
    end

    context 'signon is down' do
      it "won't rescue signon errors" do
        stub_req(endpoint).to_timeout
        expect { response }.to raise_error(Net::OpenTimeout)
      end
    end

    context 'signon request is unsuccessful' do
      it 'will raise a custom error' do
        stub_req(endpoint).to_return(
          status: 400,
          body: JSON.generate(error: 'Bad request')
        )
        expect { response }.to raise_error(SignonClient::TokenNotCreated)
      end
    end
  end

  describe '#test_bearer_token' do
    let(:endpoint) { "#{ENV['SIGNON_API_URL']}/authorisations/test" }
    subject(:response) do
      client.test_bearer_token(
        application_name: application_name,
        permissions: permissions,
        token: auth_token
      )
    end

    context 'signon request is successful' do
      it 'does not raise an error' do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(token: auth_token)
        )
        expect { response }.not_to raise_error
      end
    end

    context 'signon request fails' do
      it 'raises a custom error' do
        stub_req(endpoint).to_return(
          status: 400,
          body: JSON.generate(error: 'Token does not exist')
        )
        expect { response }.to raise_error(SignonClient::TokenNotFound)
      end
    end
  end

  def stub_req(endpoint)
    stub_request(:post, endpoint)
      .with(headers: {
              'Authorization' => "Bearer #{auth_token}",
              'Content-Type' => 'application/json'
            })
  end
end

RSpec.describe 'event handler' do
  let(:token) { 'version1' }
  let(:arn) { 'arn:secretsmanager:123' }
  let(:step) { 'invalidStep' }
  let(:event) do
    {
      'ClientRequestToken' => token,
      'SecretId' => arn,
      'Step' => step
    }
  end
  let(:context) { double }
  let(:secrets_client) do
    instance_double(Aws::SecretsManager::Client)
  end

  let(:versions) do
    {
      token => %w[AWSPENDING AWSCURRENT],
      'version2' => %w[AWSPENDING]
    }
  end

  let(:metadata) do
    double(
      rotation_enabled: true,
      version_ids_to_stages: versions
    )
  end

  let(:password) { 'password' }
  let(:admin_password) do
    double(secret_string: 'secret')
  end
  let(:app_name) { 'publishing-api' }
  let(:permissions) { 'signin' }
  let(:api_user) { 'publisher@example.org' }
  let(:generated_secret) { 'hunter2' }

  before :each do
    allow_any_instance_of(Aws::SecretsManager::Client).to \
      receive(:describe_secret)
      .with(secret_id: arn)
      .and_return(metadata)

    ENV['API_USER_EMAIL'] = api_user
    ENV['ADMIN_PASSWORD_KEY'] = password
    ENV['APPLICATION_NAME'] = app_name
    ENV['PERMISSIONS'] = permissions

    stub_admin_password
  end

  context 'setSecret' do
    subject(:call) { handler(event: event, context: context) }
    let(:step) { 'createSecret' }

    context 'rotation is disabled' do
      let(:metadata) { double(rotation_enabled: false) }
      it 'raises an error' do
        expect { call }.to raise_error NotRotatable
      end
    end

    context 'is an invalid version' do
      let(:token) { 'versionX' }
      let(:versions) { { 'version1' => %w[AWSCURRENT] } }
      it 'creates a secret in signon' do
        expect { call }.to raise_error UnknownVersion
      end
    end

    context 'is for the current version' do
      let(:versions) { { token => %w[AWSCURRENT] } }
      it "doesn't create a new token in signon" do
        expect { call }.not_to raise_error
      end
    end

    context 'has already been created' do
      let(:token) { 'version1' }
      let(:versions) { { 'version1' => %w[AWSPENDING] } }

      it 'does not create a new token' do
        stub_get_secret
          .with(secret_id: arn, version_stage: 'AWSCURRENT')

        stub_get_secret
          .with(secret_id: arn, version_stage: 'AWSPENDING', version_id: token)

        expect { call }.not_to raise_error
      end
    end

    context 'new secret' do
      let(:token) { 'version1' }
      let(:versions) { { 'version1' => %w[AWSPENDING] } }

      it 'creates a secret in signon' do
        # Control flow through try/catch :(
        stub_get_secret
          .with(secret_id: arn, version_stage: 'AWSCURRENT')
          .and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new('error', 'body'))

        stub_get_secret
          .with(secret_id: arn, version_stage: 'AWSPENDING', version_id: token)
          .and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new('error', 'body'))

        stub = stub_request(:post, /signon.example.org/)
               .with(
                 body: JSON.generate(
                   api_user_email: api_user,
                   application_name: app_name,
                   permissions: [permissions]
                 )
               )
               .to_return(
                 status: 200,
                 body: JSON.generate(token: generated_secret)
               )

        allow_any_instance_of(Aws::SecretsManager::Client).to \
          receive(:put_secret_value)
          .with(
            secret_id: arn,
            client_request_token: token,
            secret_string: generated_secret,
            version_stages: ['AWSPENDING']
          )

        expect { call }.not_to raise_error
        expect(stub).to have_been_requested
      end
    end

    context 'rotating existing secret' do
      let(:token) { 'version2' }
      let(:versions) do
        {
          'version1' => %w[AWSPENDING AWSCURRENT],
          token => %w[AWSPENDING]
        }
      end

      it 'creates a secret in signon' do
        stub_get_secret
          .with(secret_id: arn, version_stage: 'AWSCURRENT')
          .and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new('error', 'body'))

        stub = stub_request(:post, /signon.example.org/)
               .with(
                 body: JSON.generate(
                   api_user_email: api_user,
                   application_name: app_name,
                   permissions: [permissions]
                 )
               )
               .to_return(
                 status: 200,
                 body: JSON.generate(token: generated_secret)
               )

        allow_any_instance_of(Aws::SecretsManager::Client).to \
          receive(:put_secret_value)
          .with(
            secret_id: arn,
            client_request_token: token,
            secret_string: generated_secret,
            version_stages: ['AWSPENDING']
          )

        expect { call }.not_to raise_error
        expect(stub).to have_been_requested
      end
    end
  end

  context 'setSecret' do
    subject(:call) { handler(event: event, context: context) }
    let(:step) { 'setSecret' }
    let(:token) { 'version2' }
    let(:versions) do
      {
        'version1' => %w[AWSPENDING AWSCURRENT],
        token => %w[AWSPENDING]
      }
    end

    context 'the secret has been set' do
      it 'does not raise an error' do
        stub_get_secret
          .with(secret_id: arn, version_id: token, version_stage: 'AWSPENDING')

        expect { call }.not_to raise_error
      end
    end

    context 'the secret has not been set' do
      it 'raises an error' do
        stub_get_secret
          .with(secret_id: arn, version_id: token, version_stage: 'AWSPENDING')
          .and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new('error', 'body'))
        expect { call }.to raise_error Aws::SecretsManager::Errors::ResourceNotFoundException
      end
    end
  end

  context 'testSecret' do
    subject(:call) { handler(event: event, context: context) }
    let(:step) { 'testSecret' }
    let(:token) { 'version2' }
    let(:versions) do
      {
        'version1' => %w[AWSPENDING AWSCURRENT],
        token => %w[AWSPENDING]
      }
    end
    context 'the secret has been set in secretsmanager' do
      context 'the secret has been set in signon' do
        it 'does not raise an error' do
          stub_get_secret
            .with(secret_id: arn, version_id: token, version_stage: 'AWSPENDING')
            .and_return(double(secret_string: generated_secret))

          check_secret_in_signon = stub_request(:post, /signon.example.org/)
                                   .with(body: {
                                           token: generated_secret,
                                           api_user_email: api_user,
                                           application_name: app_name,
                                           permissions: permissions
                                         })
                                   .and_return(status: 200)

          expect { call }.not_to raise_error
          expect(check_secret_in_signon).to have_been_requested
        end
      end
    end
  end

  context 'finishSecret' do
    let(:step) { 'finishSecret' }
    subject(:call) { handler(event: event, context: context) }
    let(:token) { 'version2' }

    context 'secret rotation already finished' do
      let(:versions) { { token => %w[AWSCURRENT] } }
      it 'does not raise an error' do
        expect { call }.not_to raise_error
      end
    end

    context 'secret rotation not yet finished' do
      let(:old_token) { 'version1' }
      let(:versions) do
        {
          old_token => %w[AWSPENDING AWSCURRENT],
          token => %w[AWSPENDING]
        }
      end

      it 'sets the secret as finished' do
        allow_any_instance_of(Aws::SecretsManager::Client).to \
          receive(:update_secret_version_stage)
          .with(
            secret_id: arn,
            version_stage: 'AWSCURRENT',
            move_to_version_id: token,
            remove_from_version_id: old_token
          )

        expect { call }.not_to raise_error
      end
    end
  end

  def stub_get_secret
    allow_any_instance_of(Aws::SecretsManager::Client).to \
      receive(:get_secret_value)
  end

  def stub_admin_password
    stub_get_secret
      .with(secret_id: password, version_stage: 'AWSCURRENT')
      .and_return(admin_password)
  end
end
