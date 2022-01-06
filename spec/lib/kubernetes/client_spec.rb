require "spec_helper"
require "kubernetes/client"
require "base64"

RSpec.describe Kubernetes::Client do
  let(:client) do
    described_class.new(
      client: kubeclient,
      namespace: namespace,
      version: "v1",
    )
  end

  let(:kubeclient) do
    double(Kubeclient::Client)
  end

  let(:namespace) { "default" }
  let(:version) { "v1" }

  describe "#secret_exists?" do
    subject(:action) do
      client.secret_exists?(secret_name: "my-secret-name")
    end

    context "when the secret exists" do
      it "returns true" do
        allow(kubeclient).to receive(:get_secret)
          .with("my-secret-name", namespace)
          .and_return("a secret")

        expect(action).to be true
      end
    end

    context "when the secret does not exist" do
      it "returns false" do
        allow(kubeclient).to receive(:get_secret)
          .with("my-secret-name", namespace)
          .and_raise(Kubeclient::ResourceNotFoundError.new("an", "error", "message"))

        expect(action).to be false
      end
    end
  end

  describe "#put_secret_value" do
    subject(:action) do
      client.put_secret_value(
        secret_name: "my-secret-name",
        secret_data: { secret: "value" },
      )
    end

    context "when secret doesnt yet exist" do
      it "creates a secret" do
        allow(kubeclient).to receive(:get_secret)
          .with("my-secret-name", namespace)
          .and_raise(Kubeclient::ResourceNotFoundError.new("an", "error", "message"))

        allow(kubeclient).to receive(:create_secret)
          .with(
            Kubeclient::Resource.new({
              apiVersion: version,
              kind: "Secret",
              metadata: {
                name: "my-secret-name",
                namespace: namespace,
              },
              type: "Opaque",
              data: { secret: Base64.encode64("value") },
            }),
          )
          .and_return(nil)

        expect(action).to be_nil
      end
    end

    context "when secret already exists" do
      it "creates a secret" do
        allow(kubeclient).to receive(:get_secret)
          .with("my-secret-name", namespace)
          .and_return("a token")

        allow(kubeclient).to receive(:update_secret)
          .with(
            Kubeclient::Resource.new({
              apiVersion: version,
              kind: "Secret",
              metadata: {
                name: "my-secret-name",
                namespace: namespace,
              },
              type: "Opaque",
              data: { secret: Base64.encode64("value") },
            }),
          )
          .and_return(nil)

        expect(action).to be_nil
      end
    end
  end
end
