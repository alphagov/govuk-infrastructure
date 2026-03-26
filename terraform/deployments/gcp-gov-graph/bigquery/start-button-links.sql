CREATE TEMP FUNCTION resolve(origin STRING, path string) AS ((
  -- prepend a domain to a relative link
  SELECT
    CASE
      WHEN path LIKE "/%" THEN "https://www.gov.uk" || path
      WHEN path LIKE "#%" THEN origin || path
      ELSE path
    END
));

CREATE TEMP FUNCTION strip(path STRING) AS ((
  -- Remove URL parameters and anchors
  SELECT REGEXP_EXTRACT(path, "[^?#].+")
));

TRUNCATE TABLE public.start_button_links;
INSERT INTO public.start_button_links
SELECT
  id AS edition_id,
  resolve(base_path, JSON_VALUE(details, "$.transaction_start_link")) AS url,
  strip(resolve(base_path, JSON_VALUE(details, "$.transaction_start_link"))) AS url_bare,
  JSON_VALUE(details, "$.start_button_text") AS text
FROM public.publishing_api_editions_current AS editions
WHERE schema_name = "transaction"
;
