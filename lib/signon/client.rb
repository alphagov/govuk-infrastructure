require "cgi"
require "json"
require "logger"
require "net/http"
require "uri"

module Signon
  class Client
    def initialize(api_url:, auth_token:, logger: Logger.new($stdout), max_retries: 10)
      @api_url = api_url
      @auth_token = auth_token
      @max_retries = max_retries
      @logger = logger
    end

    def create_bearer_token(api_user_id:, application_id:, permissions:)
      attempt do
        req = build_post_request(
          "/api-users/#{api_user_id}/authorisations",
          {
            application_id: application_id,
            permissions: permissions,
          },
        )
        res = do_request(req)
        raise TokenNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless req_successful(res)

        JSON.parse(res.body)
      end
    end

    def test_bearer_token(api_user_id:, application_id:, token:, permissions:)
      attempt do
        req = build_post_request(
          "/api-users/#{api_user_id}/authorisations/test",
          {
            token: token,
            application_name: application_id,
            permissions: permissions,
          },
        )
        res = do_request(req)
        raise TokenNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"
      end
    end

    def create_application(name:, description:, home_uri:, permissions:, redirect_uri:)
      req = build_post_request("/applications", {
        name: name,
        description: description,
        home_uri: home_uri,
        permissions: permissions,
        redirect_uri: redirect_uri,
      })
      res = do_request(req)
      raise ApplicationAlreadyCreated if res.code_type == Net::HTTPConflict
      raise ApplicationNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless req_successful(res)

      JSON.parse(res.body)
    end

    def update_application(id:, name:, description:, permissions:)
      req = build_patch_request("/applications/#{id}", {
        name: name,
        description: description,
        permissions: permissions,
      })
      res = do_request(req)
      raise ApplicationNotFound if res.code_type == Net::HTTPNotFound
      raise ApplicationNotUpdated, "Status: #{res.code}; #{res.message}; #{res.body}" if res.code != "200"

      JSON.parse(res.body)
    end

    def get_application(name:)
      uri = URI("#{@api_url}/applications?name=#{CGI.escape name}")
      req = Net::HTTP::Get.new(uri)
      res = do_request(req)
      raise ApplicationNotFound, "Status: #{res.code}; #{res.message}; #{res.body}" unless res.code == "200"

      JSON.parse(res.body)
    end

    def create_api_user(name:, email:)
      req = build_post_request("/api-users", { name: name, email: email })
      res = do_request(req)
      raise ApiUserAlreadyCreated if res.code_type == Net::HTTPConflict
      raise ApiUserNotCreated, "Status: #{res.code}; #{res.message}; #{res.body}" unless req_successful(res)

      JSON.parse(res.body)
    end

    def get_api_user(email:)
      uri = URI("#{@api_url}/api-users?email=#{email}")
      req = Net::HTTP::Get.new(uri)
      res = do_request(req)
      if res.code_type == Net::HTTPNotFound
        raise ApiUserNotFound, "Status: #{res.code}; #{res.message}; #{res.body}"
      end

      JSON.parse(res.body)
    end

  private

    class TokenNotFound < StandardError; end

    class ApplicationNotFound < StandardError; end

    class TokenNotCreated < StandardError; end

    class ApplicationNotCreated < StandardError; end

    class ApplicationNotUpdated < StandardError; end

    class ApplicationAlreadyCreated < StandardError; end

    class ApplicationNotFound < StandardError; end

    class ApiUserAlreadyCreated < StandardError; end

    class ApiUserNotCreated < StandardError; end

    class ApiUserNotFound < StandardError; end

    def build_post_request(path, body)
      req = Net::HTTP::Post.new(URI("#{@api_url}#{path}"))
      req.body = body.to_json
      req
    end

    def build_patch_request(path, body)
      req = Net::HTTP::Patch.new(URI("#{@api_url}#{path}"))
      req.body = body.to_json
      req
    end

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

    def do_request(request)
      request["Authorization"] = "Bearer #{@auth_token}"
      request["Content-Type"] = "application/json"
      # NOTE: SSL is not enabled since requests stay in-cluster and we have not
      # configured TLS between in-cluster services.
      Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: false) do |http|
        http.request(request)
      end
    end

    def req_successful(res)
      %w[200 201].include?(res.code)
    end
  end
end
