module Factories
  module Signon
    def self.applications
      {
        "content-store" => {
          "name" => "Content Store",
          "slug" => "content-store",
          "description" => "Central store for current live content on GOV.UK",
          "home_url" => "https://content-store.test-env.publishing.service.gov.uk",
          "redirect_uri" => "https://content-store.test-env.publishing.service.gov.uk/auth/gds/callback",
          "permissions" => %w[special-access],
        },
        "publishing-api" => {
          "name" => "Publishing API",
          "slug" => "publishing-api",
          "description" => "Publishing engine",
          "home_url" => "https://publishing-api.test-env.publishing.service.gov.uk",
          "redirect_uri" => "https://publishing-api.test-env.publishing.service.gov.uk/auth/gds/callback",
        },
      }
    end

    def self.api_users
      {
        "content-store" => {
          "name" => "Content Store",
          "username" => "content-store",
          "email" => "content-store@test.publishing.service.gov.uk",
          "bearer_tokens" => [
            { "application_slug" => "publishing-api" },
          ],
        },
        "frontend" => {
          "name" => "Frontend",
          "username" => "frontend",
          "email" => "frontend@test.publishing.service.gov.uk",
          "bearer_tokens" => [
            { "application_slug" => "content-store", "permissions" => %w[internal_app] },
            { "application_slug" => "publishing-api" },
          ],
        },
      }
    end
  end
end
