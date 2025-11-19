#!/bin/bash

# Change GOVUK_ENVIRONMENT and the DBS assignment on line 66 to choose which databases to reboot
GOVUK_ENVIRONMENT=integration

# shellcheck disable=SC2034
BIG_20_DBS=(
  "account-api-postgres"
  "authenticating-proxy-postgres"
  "blue-content-data-api-postgresql-primary-postgres"
  "collections-publisher-mysql"
  "content-block-manager-postgres"
  "content-store-postgres"
  "content-tagger-postgres"
  "draft-content-store-postgres"
  "email-alert-api-postgres"
  "imminence-postgres"
  "local-links-manager-postgres"
  "locations-api-postgres"
  "publisher-postgres"
  "publishing-api-postgres"
  "search-admin-mysql"
  "signon-mysql"
  "support-api-postgres"   
  "transition-postgres"
  "whitehall-mysql"
)

# shellcheck disable=SC2034
BIG_20_DBS_NEW_NAMES=(
  "account-api-${GOVUK_ENVIRONMENT}-postgres"
  "authenticating-proxy-${GOVUK_ENVIRONMENT}-postgres"
  "content-data-api-${GOVUK_ENVIRONMENT}-postgres"
  "collections-publisher-${GOVUK_ENVIRONMENT}-mysql"
  "content-block-manager-${GOVUK_ENVIRONMENT}-postgres"
  "content-store-${GOVUK_ENVIRONMENT}-postgres"
  "content-tagger-${GOVUK_ENVIRONMENT}-postgres"
  "draft-content-store-${GOVUK_ENVIRONMENT}-postgres"
  "email-alert-api-${GOVUK_ENVIRONMENT}-postgres"
  "places-manager-${GOVUK_ENVIRONMENT}-postgres"
  "local-links-manager-${GOVUK_ENVIRONMENT}-postgres"
  "locations-api-${GOVUK_ENVIRONMENT}-postgres"
  "publisher-${GOVUK_ENVIRONMENT}-postgres"
  "publishing-api-${GOVUK_ENVIRONMENT}-postgres"
  "search-admin-${GOVUK_ENVIRONMENT}-mysql"
  "signon-${GOVUK_ENVIRONMENT}-mysql"
  "support-api-${GOVUK_ENVIRONMENT}-postgres"
  "transition-${GOVUK_ENVIRONMENT}-postgres"
  "whitehall-${GOVUK_ENVIRONMENT}-mysql"  
)

# shellcheck disable=SC2034
LITTLE_7_DBS=(
  "ckan-postgres"
  "content-data-admin-postgres"
  "release-mysql"
  "search-admin-mysql"
  "link-checker-api-postgres"
  "service-manual-publisher-postgres"
)

# shellcheck disable=SC2034
LITTLE_7_DBS_NEW_NAMES=(
  "ckan-${GOVUK_ENVIRONMENT}-postgres"
  "content-data-admin-${GOVUK_ENVIRONMENT}-postgres"
  "release-${GOVUK_ENVIRONMENT}-mysql"
  "search-admin-${GOVUK_ENVIRONMENT}-mysql"
  "link-checker-api-${GOVUK_ENVIRONMENT}-postgres"
  "service-manual-publisher-${GOVUK_ENVIRONMENT}-postgres"  
)
