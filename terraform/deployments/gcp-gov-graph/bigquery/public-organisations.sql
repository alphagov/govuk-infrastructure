-- One row per organisation, its immediate parents and successors, and all of
-- its ancestors and successors.
TRUNCATE TABLE public.organisations;
INSERT INTO public.organisations
WITH RECURSIVE
editions AS (SELECT * FROM public.publishing_api_editions_current),
organisations AS (
  SELECT
    id AS edition_id,
    JSON_VALUE(details, "$.acronym") AS acronym,
    JSON_VALUE(details, "$.brand") AS brand,
    JSON_VALUE(details, "$.organisation_type") AS organisation_type,
    JSON_VALUE(details, "$.foi_exempt") = "true" AS foi_exempt,
    JSON_VALUE(details, "$.organisation_govuk_status.status") AS organisation_status,
    CAST(JSON_VALUE(details, "$.organisation_govuk_status.updated_at") AS TIMESTAMP) AS organisation_status_updated_at,
    JSON_VALUE(details, "$.organisation_govuk_status.url") AS organisation_status_url
  FROM `public.publishing_api_editions_current`
  WHERE schema_name = "organisation"
  AND locale = 'en'
),
links AS (
  -- Non-recursive
  SELECT links.*
  FROM `public.publishing_api_links_current` AS links
  INNER JOIN organisations AS source_organisation ON source_organisation.edition_id = links.source_edition_id
  INNER JOIN organisations AS target_organisation ON target_organisation.edition_id = links.target_edition_id
  WHERE links.type IN (
    'ordered_child_organisations',
    'ordered_successor_organisations'
  )
),
link_parent_to_child AS (
  -- Non-recursive
  SELECT
    source_edition_id AS parent_edition_id,
    target_edition_id AS child_edition_id
  FROM links
  WHERE links.type = 'ordered_child_organisations'
),
ancestors AS (
  -- Recursive
  -- One row per organisation per parent organisation.
  -- Each organisation is also its own ancestor, to facilitate queries for editions
  -- that are tagged to an organisation or its sub-organisations.
  (
    SELECT
      -- One row per organisation, including top-level organisations
      edition_id,
      edition_id AS ancestor_edition_id
    FROM organisations
  )
  UNION ALL
  (
    -- Each join creates a row with the same edition_id,
    -- and the edition_id of the ancestor (parent, grandparent, great-grandparent, etc.)
    SELECT
      ancestors.edition_id,
      link_parent_to_child.parent_edition_id AS ancestor_edition_id,
    FROM ancestors
    INNER JOIN link_parent_to_child
      ON link_parent_to_child.child_edition_id = ancestors.ancestor_edition_id
  )
),
ancestors_agg AS (
  SELECT
    edition_id,
    ARRAY_AGG(DISTINCT ancestor_edition_id) AS ancestors
  FROM ancestors
  GROUP BY edition_id
),
link_predecessor_to_successor AS (
  -- Non-recursive
  SELECT
    source_edition_id AS predecessor_edition_id,
    target_edition_id AS successor_edition_id
  FROM links
  WHERE links.type = 'ordered_successor_organisations'
),
successors AS (
  -- Recursive
  -- One row per organisation per successor, up to the ultimate successor.
  -- Each organisation is also its own successor, to facilitate queries for editions
  -- that are tagged to an organisation or its successors.
  (
    SELECT
      -- One row per organisation, including original organisations
      edition_id,
      edition_id AS successor_edition_id
    FROM organisations
  )
  UNION ALL
  (
    -- Each join creates a row with the same predecessor_edition_id,
    -- and the edition_id of the successor (grandsuccessor, great-grandsuccessor, etc.)
    SELECT
      successors.edition_id,
      link_predecessor_to_successor.successor_edition_id AS edition_id
    FROM successors
    INNER JOIN link_predecessor_to_successor
      ON link_predecessor_to_successor.predecessor_edition_id = successors.successor_edition_id
  )
),
successors_agg AS (
  SELECT
    edition_id,
    ARRAY_AGG(DISTINCT successor_edition_id) AS successors
  FROM successors
  GROUP BY edition_id
),
hierarchy AS (
  -- Non-recursive
  -- One row per organisation.
  -- Its edition_id, and an array of the edition_ids of its
  -- ancestors, which include itself.
  SELECT
    organisations.*,
    (SELECT
      ARRAY_AGG(DISTINCT source_edition_id)
      FROM links
      WHERE links.target_edition_id = organisations.edition_id
      AND links.type = 'ordered_child_organisations'
    ) AS ancestors,
    (SELECT ARRAY_AGG(DISTINCT target_edition_id)
      FROM links
      WHERE links.source_edition_id = organisations.edition_id
      AND links.type = 'ordered_successor_organisations'
    ) AS immediate_successors,
    ancestors_agg.ancestors,
    successors_agg.successors AS all_successors
  FROM organisations
  LEFT JOIN ancestors_agg ON ancestors_agg.edition_id = organisations.edition_id
  LEFT JOIN successors_agg ON successors_agg.edition_id = organisations.edition_id
)
SELECT * FROM hierarchy
