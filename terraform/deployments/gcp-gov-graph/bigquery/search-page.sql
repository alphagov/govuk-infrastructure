-- A table for the GovSearch app
-- One row per 'page' (document, or part of a document that has its own URL, or
-- snippet that is included in other pages)

TRUNCATE TABLE search.page;
INSERT INTO search.page
WITH
  editions AS (
    SELECT editions.*
    FROM public.publishing_api_editions_current AS editions
    LEFT JOIN public.publishing_api_unpublishings_current
      AS unpublishings
      ON (unpublishings.edition_id = editions.id)
    WHERE (unpublishings.edition_id IS NULL OR unpublishings.type = 'withdrawal')
    AND editions.document_type NOT IN ('gone', 'redirect')
  ),
  links AS (
    SELECT *
    FROM `public.publishing_api_links_current`
  ),
  withdrawals AS (
    SELECT
      edition_id,
      unpublished_at AS withdrawn_at,
      explanation AS withdrawn_explanation
    FROM public.publishing_api_unpublishings_current
    WHERE type = 'withdrawal'
  ),
  primary_publishing_organisation AS (
    SELECT
      links.source_edition_id AS edition_id,
      editions.title AS title
    FROM links
    INNER JOIN editions ON editions.id = links.target_edition_id
    WHERE links.type = 'primary_publishing_organisation'
    -- Assume that the organisation has a document in the 'en' locale.
    -- If we allow every locale, then we will duplicate pages whose
    -- primary_publishing_organisation has documents in multiple locales.
    AND editions.locale = 'en'
  ),
  organisations AS (
    SELECT
      links.source_edition_id AS edition_id,
      ARRAY_AGG(editions.title ORDER BY links.position) AS titles
    FROM links
    INNER JOIN editions ON editions.id = links.target_edition_id
    WHERE links.type = 'organisations'
    AND editions.locale = "en"
    GROUP BY links.source_edition_id
  ),
  organisations_ancestry AS (
    SELECT
      links.source_edition_id AS edition_id,
      ARRAY_AGG(DISTINCT editions.title) AS titles
    FROM links
    INNER JOIN public.organisations ON organisations.edition_id = links.target_edition_id
    CROSS JOIN UNNEST(ancestors) AS ancestor
    INNER JOIN editions ON editions.id = ancestor
    WHERE links.type = 'organisations'
    GROUP BY links.source_edition_id
  ),
  publisher_updated_at AS (
  -- Latest updated_at date per base path in the Publisher app database.
  -- For mainstream content, this is more meaningful than the Publishing
  -- API or Content API 'updated_at' or 'public_updated_at fields.'  Mainstream
  -- editors don't tend to use 'public_updated_at', and 'updated_at' is polluted
  -- by creation of new editions for techy reasons rather than editing reasons.
  SELECT
    CONCAT("https://www.gov.uk", slug) AS url,
    MAX(updated_at) AS publisher_updated_at,
  FROM publisher.editions
  WHERE state='published'
  GROUP BY url
),
taxons AS (
  -- One row per taxon, per edition.
  -- Its edition_id, and an array of DISTINCT titles of it and its ancestors
  -- back to the root taxon.
  --
  -- This supports filtering by the name of a page's taxon or the ancestors of
  -- that taxon.
  --
  -- Taxonomy titles aren't unique. Most of them can be disambiguated by using
  -- their internal_name instead, but often the internal_name isn't suitable for
  -- use elsewhere than a publishing app. Titles seem to be duplicated when they
  -- relate to a particular country, such as "Help and services around the
  -- world", the internal name of which is "Help and services around the world
  -- (Algeria)". The GovSearch app probably shouldn't list every country's
  -- version of that taxon, so it lists the generic version. Those taxons
  -- usually have an associated_taxons link to "UK help and services in Algeria"
  -- (or whichever country) anyway, so if users need to be specific then they
  -- can filter by that taxon.
  SELECT
    links.source_edition_id AS edition_id,
    ARRAY_AGG(DISTINCT editions.title) AS titles
  FROM links
  INNER JOIN public.taxonomy ON taxonomy.edition_id = links.target_edition_id
  CROSS JOIN UNNEST(all_ancestors) AS ancestor
  INNER JOIN editions ON editions.id = ancestor.edition_id
  WHERE links.type = 'taxons'
  GROUP BY links.source_edition_id
),
all_links AS (
  SELECT
    links.type AS link_type,
    links.source_base_path AS base_path,
    "https://www.gov.uk" || links.target_base_path as link_url
  FROM links
  INNER JOIN editions ON editions.id = links.source_edition_id
  WHERE editions.base_path IS NOT NULL
  UNION ALL
  SELECT
    "embedded" as link_type,
    base_path, -- the base_path of the document or part
    hyperlink.url AS link_url
  FROM
    public.content,
    UNNEST(hyperlinks) AS hyperlink
  UNION ALL
  SELECT
    "transaction_start_link" AS link_type,
    editions.base_path,
    url AS link_url
  FROM
    public.start_button_links
  INNER JOIN editions ON editions.id = start_button_links.edition_id
),
distinct_links AS (
  SELECT DISTINCT * FROM all_links
),
interpage_links AS (
  SELECT
    base_path,
    ARRAY_AGG(
      STRUCT(
        link_url,
        link_type
      )
    ) AS hyperlinks
  FROM all_links
  GROUP BY base_path
),
phone_numbers AS (
  SELECT
    p.edition_id,
    ARRAY_AGG(phone_number.standardised_number) as phone_numbers
  FROM public.phone_numbers as p,
  UNNEST(phone_numbers) AS phone_number
  GROUP BY edition_id
),
government AS (
  SELECT
    editions.id AS edition_id,
    government.title AS government
  FROM editions
  INNER JOIN links ON links.source_edition_id = editions.id
  INNER JOIN editions AS government ON government.id = links.target_edition_id
  WHERE
    links.type = 'government'
),
people AS (
  SELECT
    editions.id AS edition_id,
    ARRAY_AGG(DISTINCT persons.title) AS people
  FROM editions
  INNER JOIN public.publishing_api_links_current AS link_edition_to_person ON link_edition_to_person.source_edition_id = editions.id
  INNER JOIN public.publishing_api_editions_current AS persons ON persons.id = link_edition_to_person.target_edition_id
  WHERE TRUE
  AND link_edition_to_person.type = "people"
  AND persons.locale = 'en'
  GROUP BY editions.id
),
pages AS (
  SELECT
    editions.id AS edition_id,
    COALESCE(content.base_path, editions.base_path) AS base_path,
    "https://www.gov.uk" || COALESCE(content.base_path, editions.base_path) AS url
  FROM editions
  LEFT JOIN public.content ON content.edition_id = editions.id
  WHERE TRUE
  AND editions.base_path IS NOT NULL
  -- Omit the first 'part' of multi-part documents, which duplicates (and is
  -- currently redirected to) the main document that has no slug. For example,
  -- include the following:
  --
  --   /main-page
  --   /main-page/second-part
  --   /main-page/third-part
  --
  -- Omit the following:
  --
  --   /main-page/first-part
  --
  -- The reason to include /main-page instead of /main-page/first-part is that
  -- no page views are recorded for /main-page/first-part.
  --
  AND (
    content.is_part IS NULL   -- Include documents that aren't multipart
    OR (NOT content.is_part)  -- Include the main page of a multipart document
    OR content.part_index > 0 -- Include parts of a multipart document, other
                              -- than the part that duplicates the main page
 )
)
SELECT
  pages.url,
  editions.document_type AS documentType,
  editions.content_id AS contentId,
  editions.locale,
  editions.publishing_app,
  editions.first_published_at,
  editions.public_updated_at,
  publisher_updated_at.publisher_updated_at,
  withdrawals.withdrawn_at,
  withdrawals.withdrawn_explanation,
  page_views.number_of_views AS page_views,
  -- content.title is "title: part title" if it is a part of a document, but it
  -- doesn't include every schema_name, so fall back to editions.title.
  COALESCE(content.title, editions.title) AS title,
  editions.description,
  content.text,
  taxons.titles AS taxons,
  primary_publishing_organisation.title AS primary_organisation,
  COALESCE(organisations.titles, []) AS organisations,
  COALESCE(people.people, []) AS people,
  COALESCE(organisations_ancestry.titles, []) AS organisations_ancestry,
  interpage_links.hyperlinks,
  phone_numbers.phone_numbers,
  JSON_VALUE(editions.details, "$.political") = 'true' AS is_political,
  government.government
FROM pages
INNER JOIN editions ON editions.id = pages.edition_id -- one row per document
LEFT JOIN withdrawals ON withdrawals.edition_id = pages.edition_id
LEFT JOIN primary_publishing_organisation ON primary_publishing_organisation.edition_id = pages.edition_id
LEFT JOIN organisations ON organisations.edition_id = pages.edition_id
LEFT JOIN organisations_ancestry ON organisations_ancestry.edition_id = pages.edition_id
LEFT JOIN phone_numbers ON phone_numbers.edition_id = pages.edition_id
LEFT JOIN taxons ON taxons.edition_id = pages.edition_id
LEFT JOIN people ON people.edition_id = pages.edition_id -- includes the slug of parts
-- one publisher_updated_at per multipart document
LEFT JOIN publisher_updated_at ON STARTS_WITH(pages.url || "/", publisher_updated_at.url || "/")
LEFT JOIN public.content -- one row per document or part
  ON content.base_path = pages.base_path -- includes the slug of parts
LEFT JOIN interpage_links
  ON interpage_links.base_path = pages.base_path -- includes the slug of parts
LEFT JOIN private.page_views
  ON page_views.url = pages.url -- includes the slug of parts
LEFT JOIN government ON government.edition_id = pages.edition_id
;
