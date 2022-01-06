require "kubeclient"
require "base64"

module Kubernetes
  class Client
    def initialize(client:, namespace:, version:)
      @client = client
      @namespace = namespace
      @version = version
    end

    def secret_exists?(secret_name:)
      client.get_secret(secret_name, namespace)
      true
    rescue Kubeclient::ResourceNotFoundError
      false
    end

    def put_secret_value(secret_name:, secret_data: {})
      resource = Kubeclient::Resource.new({
        apiVersion: version,
        kind: "Secret",
        metadata: {
          name: secret_name,
          namespace: namespace,
        },
        type: "Opaque",
        data: secret_data.transform_values { |v| Base64.encode64(v.to_s) },
      })

      return client.create_secret(resource) unless secret_exists?(secret_name: secret_name)

      client.update_secret(resource)
    end

  private

    attr_reader :namespace, :client, :version
  end
end
