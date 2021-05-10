require "signon/client"

RSpec.describe Signon::Client do
  let(:api_url) { "https://signon.example.org" }
  let(:api_user) { "publisher@example.org" }
  let(:auth_token) { "hunter2" }
  let(:application_name) { "publishing-api" }
  let(:permissions) { "signin,publish" }

  let(:client) do
    described_class.new(api_url: api_url, api_user: api_user, auth_token: auth_token, max_retries: 0)
  end

  describe "#create_bearer_token" do
    subject(:response) do
      client.create_bearer_token(
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

  def stub_req(endpoint)
    stub_request(:post, endpoint)
      .with(headers: {
        "Authorization" => "Bearer #{auth_token}",
        "Content-Type" => "application/json",
      })
  end
end
