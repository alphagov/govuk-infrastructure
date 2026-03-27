-- A table of unique locales, for a drop-down menu.
TRUNCATE TABLE search.locale;
INSERT INTO search.locale
SELECT DISTINCT locale
FROM public.publishing_api_editions_current
