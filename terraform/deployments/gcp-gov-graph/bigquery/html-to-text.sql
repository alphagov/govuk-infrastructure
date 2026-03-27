CREATE OR REPLACE FUNCTION `${project_id}.functions.html_to_text`(html STRING)
RETURNS STRING
REMOTE WITH CONNECTION `${project_id}.${region}.html-to-text`
OPTIONS (
  endpoint = "${uri}",
  max_batching_rows=1
)
