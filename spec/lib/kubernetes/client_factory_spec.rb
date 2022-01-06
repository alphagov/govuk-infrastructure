require "spec_helper"
require "kubernetes/client"
require "kubernetes/client_factory"

RSpec.describe Kubernetes::ClientFactory do
  describe "#create" do
    subject(:client) do
      described_class.create(options)
    end

    let(:options) do
      {
        kubernetes_version: "v1",
        controle_plane_uri: "https://k8s.example.org/api/v1",
        bearer_token_file: "/tmp/bearer_token",
        crt_file: "/tmp/crt_file",
        namespace_file: "/tmp/namespace",
      }
    end

    let(:kubeclient) { double(Kubeclient::Client) }
    let(:secrets_client) { double(Kubernetes::Client) }

    it "inits the kubeclient" do
      allow(File).to receive(:read).with(options[:namespace_file]).and_return("default")
      allow(File).to receive(:open).with(options[:bearer_token_file]).and_return("token")
      allow(File).to receive(:exists?).with(options[:crt_file]).and_return(true)
      allow(File).to receive(:open).with(options[:crt_file]).and_return("crt")

      allow(Kubeclient::Client).to receive(:new)
        .with(
          "https://kubernetes.default.svc",
          "v1",
          {
            auth_options: { bearer_token_file: options[:bearer_token_file] },
            ssl_options: {},
          },
        )
        .and_return(kubeclient)

      allow(Kubernetes::Client).to receive(:new)
        .with(client: kubeclient, namespace: "default", version: "v1")
        .and_return(secrets_client)

      expect(client).to eq(secrets_client)
    end
  end
end
