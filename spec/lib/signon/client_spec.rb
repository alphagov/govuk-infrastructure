require "signon/client"
require "securerandom"

RSpec.describe Signon::Client do
  let(:api_url) { "http://signon.example.org" }
  let(:api_user_email) { "publisher@example.org" }
  let(:api_user_id) { SecureRandom.hex(3) }
  let(:auth_token) { "hunter2" }
  let(:application_name) { "publishing-api" }
  let(:application_id) { SecureRandom.hex(3) }
  let(:permissions) { "signin,publish" }

  let(:client) do
    logger = Logger.new($stdout)
    logger.level = Logger::WARN
    described_class.new(api_url: api_url, auth_token: auth_token, max_retries: 0, logger: logger)
  end

  describe "#create_bearer_token" do
    subject(:response) do
      client.create_bearer_token(
        api_user_id: api_user_id,
        application_id: application_id,
        permissions: permissions,
      )
    end

    let(:endpoint) { "#{api_url}/api-users/#{api_user_id}/authorisations" }

    context "when signon request is successful" do
      it "creates a bearer token" do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(token: auth_token),
        )
        expect(response).to eq({ "token" => auth_token })
      end
    end

    context "when signon is down" do
      it "won't rescue signon errors" do
        stub_req(endpoint).to_timeout
        expect { response }.to raise_error(Net::OpenTimeout)
      end
    end

    context "when signon request is unsuccessful" do
      it "will raise a custom error" do
        stub_req(endpoint).to_return(
          status: 400,
          body: JSON.generate(error: "Bad request"),
        )
        expect { response }.to raise_error(Signon::Client::TokenNotCreated)
      end
    end
  end

  describe "#test_bearer_token" do
    subject(:response) do
      client.test_bearer_token(
        api_user_id: api_user_id,
        application_id: application_id,
        permissions: permissions,
        token: auth_token,
      )
    end

    let(:endpoint) { "#{api_url}/api-users/#{api_user_id}/authorisations/test" }

    context "when signon request is successful" do
      it "does not raise an error" do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(token: auth_token),
        )
        expect { response }.not_to raise_error
      end
    end

    context "when signon request fails" do
      it "raises a custom error" do
        stub_req(endpoint).to_return(
          status: 400,
          body: JSON.generate(error: "Token does not exist"),
        )
        expect { response }.to raise_error(Signon::Client::TokenNotFound)
      end
    end
  end

  describe "#create_application" do
    subject(:response) do
      client.create_application(
        name: "app",
        description: "app desc",
        home_uri: "https://app.example.org",
        permissions: %w[signin],
        redirect_uri: "https://app.example.org/gds/auth/callback",
      )
    end

    let(:endpoint) { "#{api_url}/applications" }

    context "when signon request is successful" do
      let(:res) { { "oauth_id" => "a", "oauth_secret" => "b" } }

      it "does not raise an error" do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(res),
        )
        expect { response }.not_to raise_error
        expect(response).to eq res
      end
    end

    context "when application already exists" do
      it "raises a custom error" do
        stub_req(endpoint).to_return(
          status: 409,
          body: JSON.generate(error: "ApplicationAlreadyCreated"),
        )
        expect { response }.to raise_error(Signon::Client::ApplicationAlreadyCreated)
      end
    end

    context "when signon request fails" do
      it "raises a custom error" do
        stub_req(endpoint).to_return(
          status: 400,
          body: JSON.generate(error: "Invalid request"),
        )
        expect { response }.to raise_error(Signon::Client::ApplicationNotCreated)
      end
    end
  end

  describe "#update_application" do
    subject(:response) do
      client.update_application(
        id: 1,
        name: "app",
        description: "new desc",
        permissions: %w[new_premission],
      )
    end

    let(:endpoint) { "#{api_url}/applications/1" }

    context "when signon request is successful" do
      let(:res) do
        {
          "id" => 1,
          "name" => "app",
          "description" => "new desc",
          "oauth_id" => "a",
          "oauth_secret" => "b",
          "permissions" => %w[new_premission],
        }
      end

      it "does not raise an error" do
        stub_req(endpoint, method: :patch).to_return(
          status: 200, body: JSON.generate(res),
        )
        expect { response }.not_to raise_error
        expect(response).to eq res
      end
    end

    context "when application does not exist" do
      it "raises a custom error" do
        stub_req(endpoint, method: :patch).to_return(status: 404)
        expect { response }.to raise_error(Signon::Client::ApplicationNotFound)
      end
    end
  end

  describe "#get_application" do
    subject(:response) do
      client.get_application(name: "Publishing API")
    end

    let(:endpoint) { "#{api_url}/applications?name=Publishing+API" }

    context "when signon request is successful" do
      let(:res) { { "id" => application_id, "oauth_id" => "a", "oauth_secret" => "b" } }

      it "does not raise an error" do
        stub_req(endpoint, method: :get)
          .to_return(status: 200, body: JSON.generate(res))
        expect { response }.not_to raise_error
        expect(response).to eq res
      end
    end

    context "when an application isn't found" do
      it "raises a custom error" do
        stub_req(endpoint, method: :get).to_return(status: 404)
        expect { response }.to raise_error(Signon::Client::ApplicationNotFound)
      end
    end
  end

  describe "#create_api_user" do
    subject(:response) do
      client.create_api_user(name: "My user", email: api_user_email)
    end

    before do
      stub_req("#{api_url}/api-users")
        .with(body: { name: "My user", email: api_user_email })
        .to_return(status: status, body: JSON.generate(res))
    end

    context "when api_user already exists" do
      let(:res) { { "error" => "Validation failed: Email has already been taken" } }
      let(:status) { 409 }

      it "returns a custom error" do
        expect { response }.to raise_error(Signon::Client::ApiUserAlreadyCreated)
      end
    end

    context "when api_user is new" do
      let(:res) { { "id" => api_user_id } }
      let(:status) { 201 }

      it "returns the api_user_id" do
        expect(response).to eq(res)
      end
    end
  end

  describe "#get_api_user" do
    subject(:response) do
      client.get_api_user(email: api_user_email)
    end

    before do
      stub_req("#{api_url}/api-users?email=#{api_user_email}", method: :get)
        .to_return(status: status, body: JSON.generate(res))
    end

    context "when the user exists" do
      let(:status) { 200 }
      let(:res) { { "id" => api_user_id } }

      it "returns the user" do
        expect(response).to eq(res)
      end
    end

    context "when the user does not exist" do
      let(:status) { 404 }
      let(:res) { { "error" => "stubbed error message - user does not exist" } }

      it "raises a custom error" do
        expect { response }.to raise_error(Signon::Client::ApiUserNotFound)
      end
    end
  end

  def stub_req(endpoint, method: :post)
    stub_request(method, endpoint)
      .with(headers: {
        "Authorization" => "Bearer #{auth_token}",
        "Content-Type" => "application/json",
      })
  end
end
