require "signon/client"

RSpec.describe Signon::Client do
  let(:api_url) { "https://signon.example.org" }
  let(:api_user) { "publisher@example.org" }
  let(:auth_token) { "hunter2" }
  let(:application_name) { "publishing-api" }
  let(:permissions) { "signin,publish" }

  let(:client) do
    logger = Logger.new(STDOUT)
    logger.level = Logger::WARN
    described_class.new(api_url: api_url, auth_token: auth_token, max_retries: 0, logger: logger)
  end

  describe "#create_bearer_token" do
    subject(:response) do
      client.create_bearer_token(
        api_user: api_user,
        application_name: application_name,
        permissions: permissions,
      )
    end

    let(:endpoint) { "#{api_url}/authorisations" }

    context "when signon request is successful" do
      it "creates a bearer token" do
        stub_req(endpoint).to_return(
          status: 200, body: JSON.generate(token: auth_token),
        )
        expect(response).to eq(auth_token)
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
        api_user: api_user,
        application_name: application_name,
        permissions: permissions,
        token: auth_token,
      )
    end

    let(:endpoint) { "#{api_url}/authorisations/test" }

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

  describe "#get_application" do
    subject(:response) do
      client.get_application(name: "[Workspace] Publishing API")
    end

    let(:endpoint) { "#{api_url}/applications?name=%5BWorkspace%5D+Publishing+API" }

    context "when signon request is successful" do
      let(:res) { { "oauth_id" => "a", "oauth_secret" => "b" } }

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

  def stub_req(endpoint, method: :post)
    stub_request(method, endpoint)
      .with(headers: {
        "Authorization" => "Bearer #{auth_token}",
        "Content-Type" => "application/json",
      })
  end
end
