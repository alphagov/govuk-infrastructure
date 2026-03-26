-- Recreate the legacy content.title table from the 'public' dataset

TRUNCATE TABLE content.title;
INSERT INTO content.title
SELECT
  "https://www.gov.uk" || COALESCE(base_path) AS url,
  title
FROM public.publishing_api_editions_current
WHERE base_path IS NOT NULL
AND title IS NOT NULL
;
