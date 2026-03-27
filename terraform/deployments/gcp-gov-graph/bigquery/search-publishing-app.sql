-- A table of unique publishing applications, for a drop-down menu.
TRUNCATE TABLE search.publishing_app;
INSERT INTO search.publishing_app
SELECT DISTINCT publishing_app
FROM public.publishing_api_editions_current
