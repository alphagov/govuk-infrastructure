require "json"
require "logger"
require "net/http"
require "uri"

# TODO: This client duplicates the client used by the Lambda rotation function.
# The only difference in the Lambda is use_ssl is false. Include this client
# in the Lambda rather than duplicating the code.
module Signon
  class Client
    def initialize(api_url:, api_user:, auth_token:, logger: Logger.new($stdout), max_retries: 9)
      @api_url = api_url
      @api_user = api_user
      @auth_token = auth_token
      @max_retries = max_retries
      @logger = logger
    end

    def create_bearer_token(application_name:, permissions:)
      attempt do
        uri = URI("#{@api_url}/authorisations")
        req = Net::HTTP::Post.new(uri)
        req.body = {
          api_user_email: @api_user,
          application_name: application_name,
          permissions: permissions,
        }.to_json
        res = do_request(req, uri)
        raise TokenNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless %w[200 201].include?(res.code)

        JSON.parse(res.body).fetch("token")
      end
    end

    def test_bearer_token(token:, application_name:, permissions:)
      attempt do
        uri = URI("#{@api_url}/authorisations/test")
        req = Net::HTTP::Post.new(uri)
        req.body = {
          token: token,
          api_user_email: @api_user,
          application_name: application_name,
          permissions: permissions,
        }.to_json
        res = do_request(req, uri)
        raise TokenNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"
      end
    end

  private

    class TokenNotFound < StandardError; end

    class TokenNotCreated < StandardError; end

    def attempt(&request)
      retries ||= 0
      begin
        yield request
      rescue TokenNotFound, TokenNotCreated
        if (retries += 1) <= @max_retries
          @logger.info "Rescued failed attempt. Attempts remaining: #{@max_retries - retries}."
          sleep(2**retries)
          retry
        else
          @logger.info "#{@max_retries} attempts failed. Bailing out."
          raise
        end
      end
    end

    def do_request(request, uri)
      request["Authorization"] = "Bearer #{@auth_token}"
      request["Content-Type"] = "application/json"
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end
  end
end
