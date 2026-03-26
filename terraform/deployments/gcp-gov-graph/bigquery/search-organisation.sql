-- A table of unique organisation titles, for a drop-down menu.
TRUNCATE TABLE search.organisation;
INSERT INTO search.organisation
SELECT title
FROM public.publishing_api_editions_current
WHERE
  TRUE
  AND schema_name = 'organisation'
  AND locale = 'en'
