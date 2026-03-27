-- A table of unique person titles, for a drop-down menu.
TRUNCATE TABLE search.person;
INSERT INTO search.person
SELECT title
FROM public.publishing_api_editions_current
WHERE
  TRUE
  AND schema_name = 'person'
  AND locale = 'en'
