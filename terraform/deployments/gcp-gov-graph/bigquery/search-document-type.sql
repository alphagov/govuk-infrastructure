-- A table of document types, for a drop-down menu.
TRUNCATE TABLE search.document_type;
INSERT INTO search.document_type
SELECT DISTINCT document_type
FROM public.publishing_api_editions_current
