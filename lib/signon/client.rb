require "cgi"
require "json"
require "logger"
require "net/http"
require "uri"

# TODO: This client duplicates the client used by the Lambda rotation function.
# Require this client from the Lambda rather than duplicating the code.
module Signon
  class Client
    def initialize(api_url:, auth_token:, logger: Logger.new($stdout), max_retries: 9)
      @api_url = api_url
      @auth_token = auth_token
      @max_retries = max_retries
      @logger = logger
    end

    def create_bearer_token(api_user:, application_name:, permissions:)
      attempt do
        uri = URI("#{@api_url}/authorisations")
        req = Net::HTTP::Post.new(uri)
        req.body = {
          api_user_email: api_user,
          application_name: application_name,
          permissions: permissions,
        }.to_json
        res = do_request(req, uri)
        raise TokenNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless %w[200 201].include?(res.code)

        JSON.parse(res.body).fetch("token")
      end
    end

    def test_bearer_token(api_user:, token:, application_name:, permissions:)
      attempt do
        uri = URI("#{@api_url}/authorisations/test")
        req = Net::HTTP::Post.new(uri)
        req.body = {
          token: token,
          api_user_email: api_user,
          application_name: application_name,
          permissions: permissions,
        }.to_json
        res = do_request(req, uri)
        raise TokenNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"
      end
    end

    def create_application(name:, description:, home_uri:, permissions:, redirect_uri:)
      uri = URI("#{@api_url}/applications")
      req = Net::HTTP::Post.new(uri)
      req.body = {
        name: name,
        description: description,
        home_uri: home_uri,
        permissions: permissions,
        redirect_uri: redirect_uri,
      }.to_json
      res = do_request(req, uri)
      raise ApplicationAlreadyCreated if already_exists(res)
      raise ApplicationNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless %w[200 201].include?(res.code)

      JSON.parse(res.body)
    end

    def get_application(name:)
      uri = URI("#{@api_url}/applications?name=#{CGI.escape name}")
      req = Net::HTTP::Get.new(uri)
      res = do_request(req, uri)
      raise ApplicationNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"

      JSON.parse(res.body)
    end

  private

    class TokenNotFound < StandardError; end
    class ApplicationNotFound < StandardError; end
    class TokenNotCreated < StandardError; end
    class ApplicationNotCreated < StandardError; end
    class ApplicationAlreadyCreated < StandardError; end
    class ApplicationNotFound < StandardError; end

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

    def already_exists(res)
      # TODO: Remove deprecated check once
      deprecated = res.code == "400" && JSON.parse(res.body).dig("error") == "Record already exists"
      new = res.code == "409"
      new || deprecated
    end
  end
end
