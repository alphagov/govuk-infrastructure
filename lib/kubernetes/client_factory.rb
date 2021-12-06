require "kubeclient"

module Kubernetes
  module ClientFactory
    DEFAULTS = {
      kubernetes_version: "v1",
      control_plane_uri: "https://kubernetes.default.svc",
      bearer_token_file: "/var/run/secrets/kubernetes.io/serviceaccount/token",
      ca_file: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
      namespace_file: "/var/run/secrets/kubernetes.io/serviceaccount/namespace",
    }.freeze

    def self.create(options = {})
      options = DEFAULTS.merge(options)
      crt_file = options[:ca_file]
      ssl_options = {}
      ssl_options[:ca_file] = crt_file if File.exist?(crt_file)
      Kubernetes::Client.new(
        client: Kubeclient::Client.new(
          options[:control_plane_uri],
          options[:kubernetes_version],
          {
            auth_options: {
              bearer_token_file: options[:bearer_token_file],
            },
            ssl_options: ssl_options,
          },
        ),
        namespace: File.read(options[:namespace_file]),
        version: options[:kubernetes_version],
      )
    end
  end
end
