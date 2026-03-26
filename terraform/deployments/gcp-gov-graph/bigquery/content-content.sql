-- Recreate the legacy content.content table from the 'public' dataset

TRUNCATE TABLE content.content;
INSERT INTO content.content
SELECT
  "https://www.gov.uk" || COALESCE(content.base_path, "/" || editions.content_id) AS url,
  html,
  text,
  ARRAY_TO_STRING(ARRAY_AGG(line.line), "\n") AS text_without_blank_lines
FROM public.content
INNER JOIN public.publishing_api_editions_current AS editions ON editions.id = content.edition_id
CROSS JOIN unnest(lines) AS line
WHERE TRIM(line.line) <> ""
GROUP BY
  url,
  html,
  text
