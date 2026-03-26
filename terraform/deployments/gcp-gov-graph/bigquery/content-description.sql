-- Recreate the legacy content.description table from the 'public' dataset

TRUNCATE TABLE content.description;
INSERT INTO content.description
SELECT
  "https://www.gov.uk" || COALESCE(base_path) AS url,
  description
FROM public.publishing_api_editions_current
WHERE base_path IS NOT NULL
AND description IS NOT NULL
AND description <> ""
;
