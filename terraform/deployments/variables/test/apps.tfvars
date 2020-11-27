#--------------------------------------------------------------
# App variables
#--------------------------------------------------------------

app_domain               = "test.govuk.digital" # TODO: changed from test.publishing.service.gov.uk for easier testing.
app_domain_internal      = "test.govuk-internal.digital"
govuk_environment        = "test"
mongodb_host             = "mongo-1.test.govuk-internal.digital,mongo-2.test.govuk-internal.digital,mongo-3.test.govuk-internal.digital"
redis_host               = "shared-redis.test.govuk-internal.digital"
sentry_environment       = "test"
router_mongodb_url       = "mongodb://router-backend-1.test.govuk-internal.digital,router-backend-2.test.govuk-internal.digital,router-backend-3.test.govuk-internal.digital/router"
draft_router_mongodb_url = "mongodb://router-backend-1.test.govuk-internal.digital,router-backend-2.test.govuk-internal.digital,router-backend-3.test.govuk-internal.digital/draft_router"
signon_db_url            = "mysql2://root:root@mysql-primary.test.govuk-internal.digital/signon"
signon_test_db_url       = "mysql2://root:root@mysql-primary.test.govuk-internal.digital/signon_test"
