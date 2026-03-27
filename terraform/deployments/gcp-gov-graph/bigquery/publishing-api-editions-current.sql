-- Maintains a table `public.publishing_api_editions_current` of one record per
-- document as it currently appears on the GOV.UK website and in the Content
-- API.
--
-- 1. Filter for editions that are new since the last batch.
-- 2. Filter those editions for the latest one per document.
-- 3. Delete corresponding editions from public.publishing_api_editions_current.
-- 4. Insert the new current editions into public.publishing_api_editions_current.

BEGIN

-- Refresh the table of editions that are new since the previous batch.
TRUNCATE TABLE private.publishing_api_editions_new_current;
INSERT INTO private.publishing_api_editions_new_current
SELECT
  documents.content_id,
  documents.locale,
  editions.*,
  unpublishings.type AS unpublishing_type,
  -- indicate whether it has a presence online (whether a redirect, or
  -- embedded in other pages, or a page in its own right).
  (
    coalesce(content_store = 'live', false) -- Includes items that are only embedded in others.
    AND state <> 'superseded' -- Exclude this rare and illogical case
    AND coalesce(unpublishings.type <> 'vanish', true)
    AND (
      coalesce(left(schema_name, 11) <> 'placeholder', true)
      OR (
        -- schema_name must be checked again because short-circuit evaluation
        -- isn't available in this clause.
        coalesce(left(schema_name, 11) = 'placeholder', false)
        AND coalesce(unpublishings.type IN ('gone', 'redirect'), false)
      )
    )
  ) AS is_online
FROM publishing_api.editions
INNER JOIN publishing_api.documents ON documents.id = editions.document_id
LEFT JOIN private.publishing_api_editions_current ON
  -- same document
  publishing_api_editions_current.document_id = editions.document_id
  -- equal/more recent edition
  AND publishing_api_editions_current.updated_at >= editions.updated_at
-- if there isn't an equal/more recent edition, then this is a new edition
LEFT JOIN publishing_api.unpublishings ON unpublishings.edition_id = editions.id
WHERE publishing_api_editions_current.document_id IS NULL
AND state <> 'draft'
QUALIFY ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY updated_at DESC) = 1
;

-- Refresh the table of the current edition of each document.
TRUNCATE TABLE private.publishing_api_editions_current;
INSERT INTO private.publishing_api_editions_current
SELECT
  editions.document_id,
  editions.updated_at
FROM publishing_api.editions
WHERE state <> 'draft'
QUALIFY ROW_NUMBER() OVER (PARTITION BY document_id ORDER BY updated_at DESC) = 1
;

-- Insert new editions into the public.editions_new_current table, if they are
-- also 'online', which means that they are publicly available via the website
-- or the Content API. Scrub certain columns of editions that are redirected or
-- 'gone', and omit columns that aren't in the Content API at all.
-- https://github.com/alphagov/publishing-api/tree/d041ae94a48fec9bd623bbb36ae6e87820ea0b06/app/presenters
--
-- These could go straight into public.publishing_api_editions_current, but it's
-- more efficient to put them here, so that we can do downstream processing of
-- only the new editions, without querying all the existing editions.
TRUNCATE TABLE public.publishing_api_editions_new_current;
INSERT INTO public.publishing_api_editions_new_current
SELECT *
    EXCEPT (
      created_at,
      last_edited_at,
      state,
      user_facing_version,
      content_store,
      publishing_request_id,
      major_published_at,
      publishing_api_first_published_at,
      publishing_api_last_edited_at,
      auth_bypass_ids,
      is_online,
      last_edited_by_editor_id
    )
    REPLACE (
      IF(unpublishing_type IN ('redirect', 'gone'), unpublishing_type, document_type) AS document_type,
      IF(unpublishing_type IN ('redirect', 'gone'), unpublishing_type, schema_name) AS schema_name,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, title) AS title,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, rendering_app) AS rendering_app,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, analytics_identifier) AS analytics_identifier,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, first_published_at) AS first_published_at,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, description) AS description,
      IF(unpublishing_type IN ('redirect', 'gone'), NULL, details) AS details
    )
FROM private.publishing_api_editions_new_current
WHERE is_online
;

-- Delete rows from the public.publishing_api_editions_current table where a
-- newer edition of the same document is now available.  The newer edition might
-- be private, so use the private editions as the source of the merge.
MERGE INTO
public.publishing_api_editions_current AS target
USING private.publishing_api_editions_new_current AS source
ON source.document_id = target.document_id
-- Sometimes an edition id is reused, e.g. if it has been used initially by a
-- test in a non-production environment (which is where GovGraph gets its data,
-- as of 2025-05), and then used again for real in production.
OR source.id = target.id
WHEN matched THEN DELETE
;

-- Insert new, public editions into the
-- public.publishing_api_editions_current table.
INSERT INTO public.publishing_api_editions_current
SELECT * FROM public.publishing_api_editions_new_current
;

END
