-- Recreate the legacy content.expanded_links table from the 'public' dataset
--
-- This isn't even nearly the same, because the Content API names and structures
-- several types of links differently.
--
-- The only known dependency of the original content.expanded_links table only
-- uses the 'parent' link type, which is faithfully reproduced here.
--
-- One type that doesn't exist in the Publishing API is 'children', which seems
-- to be derived as the inverse of 'parent.  Another is 'policy_areas', which is
-- only used by the Email API, and perhaps is defined there.

TRUNCATE TABLE content.expanded_links;
INSERT INTO content.expanded_links
WITH
  editions AS (
    SELECT *
    FROM public.publishing_api_editions_current AS editions
  )
SELECT
  links.type AS link_type,
  "https://www.gov.uk" || sources.base_path as from_url,
  "https://www.gov.uk" || targets.base_path as to_url
FROM
  public.publishing_api_links_current AS links
INNER JOIN editions AS sources ON sources.id = links.source_edition_id
INNER JOIN editions AS targets ON targets.id = links.target_edition_id
WHERE TRUE
  AND sources.base_path IS NOT NULL
  AND targets.base_path IS NOT NULL
