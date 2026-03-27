-- Refresh a table that maps base paths used in the real world to base paths
-- that belong to editions in the Publishing API database.  The difference is
-- due to documents of schema 'guide' and 'travel_advice' having a real-world
-- base_path for each part of the document.
--
-- This query depends on the table public.content, which extracts the extra
-- slugs of 'guide' and 'travel_advice' documents.  The public.content table
-- can't itself be used as a lookup table, because it omits documents that don't
-- have content, or whose content we don't yet extract.
TRUNCATE TABLE public.base_path_lookup;
INSERT INTO public.base_path_lookup
WITH real_base_paths AS (
  SELECT
    id AS edition_id,
    base_path
  FROM public.publishing_api_editions_current
  WHERE base_path IS NOT NULL
  UNION DISTINCT
  SELECT
    edition_id,
    base_path
  FROM public.content
  WHERE base_path IS NOT NULL
)
SELECT
  real_base_paths.base_path AS base_path_for_joining,
  editions.base_path AS publishing_api_base_path,
  editions.id AS edition_id,
  editions.content_id
FROM real_base_paths
INNER JOIN public.publishing_api_editions_current AS editions
  ON editions.id = real_base_paths.edition_id
