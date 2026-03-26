-- One row per taxon.
-- Its parent, its associated taxon (if any), its ancestor taxons via both its
-- parent and associated taxons, including itself as its own ancestor.
-- Top-level taxons are included.
-- Assumes each taxon has at most one parent, and at most one associated taxon.

TRUNCATE TABLE public.taxonomy;
INSERT INTO public.taxonomy
WITH RECURSIVE
taxon_links AS (
  -- Links of the taxonomy tree and other associations between taxons
  -- One row per link, per taxon
  -- Its own ID, the ID of its linked taxon, and the type of link
  select
    links.type,
    links.source_edition_id,
    links.target_edition_id
    FROM public.publishing_api_links_current AS links
    -- Exclude unpublished editions (note that an 'unpublished' edition isn't
    -- necessarily offline, e.g. redirects and 'gone')
    LEFT JOIN public.publishing_api_unpublishings_current
      AS source_unpublishings
      ON (source_unpublishings.edition_id = links.source_edition_id)
    LEFT JOIN public.publishing_api_unpublishings_current
      AS target_unpublishings
      ON (target_unpublishings.edition_id = links.target_edition_id)
    WHERE links.type IN ('parent_taxons', 'root_taxon', 'associated_taxons')
    AND source_unpublishings.edition_id IS NULL
    AND target_unpublishings.edition_id IS NULL
),
association AS (
  -- Non-recursive.
  -- One row per taxon.
  -- Its own ID, and the IDs of its associated taxon (if any).
  -- Assumes at most one associated taxon.
  SELECT
    source_edition_id AS edition_id,
    target_edition_id AS associated_edition_id
  FROM taxon_links
  WHERE type = 'associated_taxons'
),
parentage AS (
  -- Non-recursive.
  -- One row per taxon, omitting top-level taxons.
  -- Its own ID, and the ID of its parent, if any.
  -- Assumes at most one parent.
  SELECT
    source_edition_id AS edition_id,
    target_edition_id AS parent_edition_id
  FROM taxon_links
  WHERE type IN ('parent_taxons', 'root_taxon')
),
taxons AS (
  -- Non-recursive.
  -- One row per taxon, including top-level taxons.
  SELECT
    edition_id
  FROM parentage
  UNION DISTINCT
  SELECT
    parent_edition_id AS edition_id,
  FROM parentage
  UNION DISTINCT
  SELECT
    id
  FROM public.publishing_api_editions_current
  WHERE schema_name = 'taxon'
),
levels AS (
  -- Recursive.
  -- One row per taxon, omitting top-level taxons.
  -- Its own ID, and its parent's ID, and its level in the tree
  (
    -- The base case, top-level taxons.
    SELECT DISTINCT
      parent_edition_id AS edition_id,
      parent_edition_id,
      1 AS level
    FROM parentage
    WHERE parent_edition_id NOT IN (
      SELECT edition_id FROM parentage
    )
  )
  UNION ALL
  (
    -- Each join creates a row with the same ancestor_edition_id,
    -- and the edition_id of the child (grandchild, great-grandchild, etc.)
    SELECT
      parentage.edition_id,
      levels.parent_edition_id,
      levels.level + 1 AS level
    FROM levels
    INNER JOIN parentage
      ON parentage.parent_edition_id = levels.edition_id
  )
),
ancestors AS (
  -- Recursive
  -- One row per taxon per ancestor.
  -- Each taxon is also its own ancestor, to facilitate queries for editions
  -- that are tagged to a taxon or its ancestors.
  (
    SELECT
      -- One row per taxon, including top-level taxons
      edition_id,
      edition_id AS ancestor_edition_id
    FROM taxons
  )
  UNION ALL
  (
    -- Each join creates a row with the same ancestor_edition_id,
    -- and the edition_id of the child (grandchild, great-grandchild, etc.)
    SELECT
      parentage.edition_id,
      ancestors.ancestor_edition_id
    FROM ancestors
    INNER JOIN parentage
      ON parentage.parent_edition_id = ancestors.edition_id
  )
),
parentage_tree AS (
  -- Non-recursive
  -- One row per taxon.
  -- Its edition_id and level, and an array of the edition_id and level of its
  -- ancestors, which include itself.
  SELECT
    a.edition_id,
    COALESCE(taxon_levels.level, 1) AS level, -- default orphaned taxons
    ARRAY_AGG(
      STRUCT(
        a.ancestor_edition_id AS edition_id,
        COALESCE(ancestor_levels.level, 1) AS level -- default orphaned taxons
      )
      ORDER BY ancestor_levels.level DESC
    ) AS ancestors,
  FROM ancestors AS a
  LEFT JOIN levels
    AS taxon_levels
    ON taxon_levels.edition_id = a.edition_id
  LEFT JOIN levels
    AS ancestor_levels
    ON ancestor_levels.edition_id = a.ancestor_edition_id
  GROUP BY
    a.edition_id,
    taxon_levels.level
)
SELECT
  taxons.edition_id,
  parentage_tree.level,
  parentage.parent_edition_id,
  association.associated_edition_id,
  parentage_tree.ancestors AS ancestors_via_parent, -- includes itself
  ARRAY_CONCAT(
    [(STRUCT(taxons.edition_id, parentage_tree.level))], -- itself
    COALESCE(association_tree.ancestors, []) -- ancestors of its associated taxon, if any
  ) AS ancestors_via_association, -- includes itself
  `${project_id}.functions.dedup`(
    ARRAY_CONCAT(
      parentage_tree.ancestors,
      COALESCE(association_tree.ancestors, [])
    )
  ) AS all_ancestors  -- includes itself
FROM taxons
LEFT JOIN parentage USING (edition_id)
INNER JOIN parentage_tree USING (edition_id)
LEFT JOIN association ON association.edition_id = parentage.edition_id
LEFT JOIN parentage_tree AS association_tree ON association_tree.edition_id = association.associated_edition_id
;
