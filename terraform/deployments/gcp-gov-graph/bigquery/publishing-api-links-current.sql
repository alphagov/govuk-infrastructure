-- The links table includes ones to documents or editions that are no longer
-- public. Those links shouldn't be made public.
TRUNCATE TABLE public.publishing_api_links_current;
INSERT INTO public.publishing_api_links_current

WITH
edition_links AS (
  SELECT
    sources.id AS source_edition_id,
    sources.content_id AS source_content_id,
    sources.base_path AS source_base_path,
    targets.id AS target_edition_id,
    targets.content_id AS target_content_id,
    targets.base_path AS target_base_path,
    links.link_type AS type,
    links.position
  FROM publishing_api.links
  INNER JOIN public.publishing_api_editions_current AS sources
    ON (sources.id = links.edition_id)
  INNER JOIN public.publishing_api_editions_current AS targets
    ON (targets.content_id = links.target_content_id)
),
link_set_links AS (
  SELECT
    sources.id AS source_edition_id,
    sources.content_id AS source_content_id,
    sources.base_path AS source_base_path,
    targets.id AS target_edition_id,
    targets.content_id AS target_content_id,
    targets.base_path AS target_base_path,
    links.link_type AS type,
    links.position
  FROM publishing_api.links
  INNER JOIN public.publishing_api_editions_current AS sources
    ON (sources.content_id = links.link_set_content_id)
  INNER JOIN public.publishing_api_editions_current AS targets
  ON (targets.content_id = links.target_content_id)
),
-- edition_links take precedence when there are link-set links of the same type
edition_link_types AS (
  SELECT DISTINCT
    source_edition_id,
    type
  FROM edition_links
),
intact_link_set_links AS (
  SELECT link_set_links.*
  FROM link_set_links
  LEFT JOIN edition_link_types USING (source_edition_id, type)
  WHERE edition_link_types.source_edition_id IS NULL
)
SELECT * FROM edition_links
UNION ALL SELECT * FROM intact_link_set_links
