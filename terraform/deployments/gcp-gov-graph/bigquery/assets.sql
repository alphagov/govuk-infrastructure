-- Refresh a table of assets, derived from the Publishing API editions table.
TRUNCATE TABLE public.assets;
INSERT INTO public.assets
SELECT
  id AS edition_id,
  attachment_index,
  BOOL(JSON_QUERY(attachment, "$.accessible")) AS accessible,
  JSON_VALUE(attachment, "$.alternative_format_contact_email") AS alternative_format_contact_email,
  JSON_VALUE(attachment, "$.attachment_type") AS attachment_type,
  JSON_VALUE(attachment, "$.content_type") AS content_type,
  CAST(JSON_VALUE(attachment, "$.file_size") AS INT64) AS file_size,
  JSON_VALUE(attachment, "$.locale") AS locale,
  JSON_VALUE(attachment, "$.title") AS title,
  JSON_VALUE(attachment, "$.url") AS url,
  JSON_VALUE(attachment, "$.filename") AS attachment_filename,
  asset_index,
  JSON_VALUE(asset, "$.filename") AS asset_filename,
  JSON_VALUE(asset, "$.asset_manager_id") AS asset_manager_id
FROM   public.publishing_api_editions_current
CROSS JOIN
  UNNEST (JSON_QUERY_ARRAY(details, "$.attachments")) AS attachment WITH OFFSET AS attachment_index
CROSS JOIN UNNEST (JSON_QUERY_ARRAY(attachment, "$.assets")) AS asset WITH OFFSET AS asset_index
WHERE JSON_QUERY_ARRAY(details, "$.attachments") IS NOT NULL
ORDER BY id, attachment_index
;
