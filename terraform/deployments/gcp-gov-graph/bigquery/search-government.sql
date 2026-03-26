-- A table of unique government titles, for a drop-down menu.
TRUNCATE TABLE search.government;
INSERT INTO search.government
SELECT title
FROM public.publishing_api_editions_current
WHERE
  TRUE
  AND schema_name = 'government'
  AND locale = 'en'
