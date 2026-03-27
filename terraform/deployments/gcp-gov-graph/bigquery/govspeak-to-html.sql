-- returns JSON: { "html" => html, "error" => error_message }
CREATE OR REPLACE FUNCTION `${project_id}.functions.govspeak_to_html`(govspeak STRING)
RETURNS JSON
REMOTE WITH CONNECTION `${project_id}.${region}.govspeak-to-html`
OPTIONS (
  endpoint = "${uri}",
  max_batching_rows=1
)
