CREATE OR REPLACE FUNCTION `${project_id}.functions.data_loss_prevention`(text STRING, inspect_config JSON, deidentify_config JSON)
RETURNS STRING
REMOTE WITH CONNECTION `${project_id}.${region}.data-loss-prevention`
OPTIONS (
  endpoint = "${uri}",
  max_batching_rows=50000
)
