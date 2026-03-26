TRUNCATE TABLE public.publishing_api_unpublishings_current;
INSERT INTO public.publishing_api_unpublishings_current
SELECT
  unpublishings.edition_id,
  unpublishings.type,
  unpublishings.explanation,
  unpublishings.alternative_path,
  unpublishings.unpublished_at,
  unpublishings.redirects
FROM
  publishing_api.unpublishings
INNER JOIN
  public.publishing_api_editions_current
ON
  ( publishing_api_editions_current.id = unpublishings.edition_id )
