# The completion config resource is a permanent, pre-existing subresource on the datastore, so we
# never want to create it even if the state is empty.
import {
  id = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"
  to = restapi_object.google_discovery_engine_data_store_completion_config
}
