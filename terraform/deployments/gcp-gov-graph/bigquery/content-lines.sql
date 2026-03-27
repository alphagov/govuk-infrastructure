-- Recreate the legacy content.lines table from the 'public' dataset

TRUNCATE TABLE content.lines;
INSERT INTO content.lines
SELECT
  "https://www.gov.uk" || COALESCE(content.base_path, "/" || editions.content_id) AS url,
  line.line_number,
  line.line
FROM public.content
CROSS JOIN UNNEST(lines) AS line
INNER JOIN public.publishing_api_editions_current AS editions ON editions.id = content.edition_id
;
