-- Maintains a table `public.content` of
-- * one record per document if the document has a single part
-- * one record per part of multipart documents, whare the ones with schema_name
--   IN ('guide', 'travel_advice')
--
-- 1. Fetch new editions since the last batch update from
--    public.publishing_api_editions_new_current.
-- 2. Extract markup from those editions according to their schema.
-- 3. Where HTML is null, render the GovSpeak to HTML.
-- 4. Extract plain text and various HTML tags from the HTML.
-- 5. Delete outdated editions from public.content.
-- 6. Insert new editions into public.content.

BEGIN

-- Extract COALESCE(govspeak, HTML) content from a JSON array that could
-- include either or both kinds of markup.
--
-- Because govspeak is a superset of HTML, which is later rendered to HTML
-- anyway, we don't need to know which markup this function returns.
--
-- Example input:
-- [
--  {"content":"# Govspeak Content","content_type":"text/govspeak"},
--  {"content":"<h1>HTML Content</h1>","content_type":"text/html"}
-- ]
CREATE TEMP FUNCTION markup_from_json_array(array_of_json JSON)
RETURNS STRING
AS ((
    WITH keyvalues AS (
      SELECT
        JSON_VALUE(item, '$.content') AS content,
        JSON_VALUE(item, '$.content_type') AS content_type
      FROM UNNEST(JSON_QUERY_ARRAY(array_of_json)) AS item
    )
    SELECT COALESCE(govspeak, html)
    FROM keyvalues
    PIVOT(
      CAST(ANY_VALUE(content) AS STRING)
      FOR content_type IN ('text/govspeak' as govspeak, 'text/html' as html)
    )
));

-- Extract the content of a step-by-step, because not all of them are rendered
-- to the details.body field.
--
-- Links are in the JSON as separate "href" and "text" fields, which this
-- function emits as HTML. Because govspeak is a superset of HTML, you can pass
-- this into govspeak_to_html() and then extract the links.
CREATE TEMP FUNCTION extractStepContents(steps JSON)
RETURNS STRING
LANGUAGE js
AS r"""
return steps.map((step) => {
  var contents = "";
  contents += step.title;
  contents += step.contents.reduce((acc, task) => {
    switch (task.type) {
      case "paragraph":
        return acc + task.text + "\n";
      case "list":
        return acc + "- " + task.contents.map((entry) => {
          var href = `<a href="$${entry.href}">$${entry.text}</a>`
          if ("context" in entry) {
            return href + "\n" + entry.context;
          }
          return href
        }).join("\n - ") + "\n";
      default:
        return acc; // Ignore unknown types
    }
  }, "\n");
  return contents;
}).join("\n");
""";

TRUNCATE TABLE public.content_new;
INSERT INTO public.content_new
-- schema_map ought to be a table, but it would take a lot of configuration.  If
-- we used DBT or SQLMesh then it would be easier, as a seed, but those tools
-- also require a lot of configuration.
WITH

editions AS (SELECT * FROM public.publishing_api_editions_new_current),

schema_map AS (
  SELECT 'answer' AS schema_name, 'general' AS govspeak_location
  UNION ALL SELECT 'calendar', 'general'
  UNION ALL SELECT 'call_for_evidence', 'general'
  UNION ALL SELECT 'case_study', 'general'
  UNION ALL SELECT 'consultation', 'general'
  UNION ALL SELECT 'corporate_information_page', 'general'
  UNION ALL SELECT 'detailed_guide', 'general'
  UNION ALL SELECT 'document_collection', 'general'
  UNION ALL SELECT 'fatality_notice', 'general'
  UNION ALL SELECT 'help_page', 'general'
  UNION ALL SELECT 'historic_appointment', 'general'
  UNION ALL SELECT 'history', 'general'
  UNION ALL SELECT 'hmrc_manual_section', 'general'
  UNION ALL SELECT 'html_publication', 'general'
  UNION ALL SELECT 'licence', 'general'
  UNION ALL SELECT 'local_transaction', 'general'
  UNION ALL SELECT 'manual', 'general'
  UNION ALL SELECT 'manual_section', 'general'
  UNION ALL SELECT 'news_article', 'general'
  UNION ALL SELECT 'organisation', 'general'
  UNION ALL SELECT 'person', 'general'
  UNION ALL SELECT 'place', 'general'
  UNION ALL SELECT 'publication', 'general'
  UNION ALL SELECT 'role', 'general'
  UNION ALL SELECT 'service_manual_guide', 'general'
  UNION ALL SELECT 'service_manual_service_standard', 'general'
  UNION ALL SELECT 'simple_smart_answer', 'general'
  UNION ALL SELECT 'smart_answer', 'general'
  UNION ALL SELECT 'specialist_document', 'general'
  UNION ALL SELECT 'speech', 'general'
  UNION ALL SELECT 'statistical_data_set', 'general'
  UNION ALL SELECT 'statistics_announcement', 'general'
  UNION ALL SELECT 'take_part', 'general'
  UNION ALL SELECT 'topical_event', 'general'
  UNION ALL SELECT 'topical_event_about_page', 'general'
  UNION ALL SELECT 'transaction', 'general'
  UNION ALL SELECT 'working_group', 'general'
  UNION ALL SELECT 'world_location_news', 'general'
  UNION ALL SELECT 'worldwide_corporate_information_page', 'general'
  UNION ALL SELECT 'worldwide_office', 'general'
  UNION ALL SELECT 'worldwide_organisation', 'general'

  UNION ALL SELECT 'guide', 'part'
  UNION ALL SELECT 'travel_advice', 'part'

  UNION ALL SELECT 'step_by_step_nav', 'step_by_step_nav'
),

general AS (
  SELECT
    editions.id AS edition_id,
    editions.document_id,
    editions.schema_name,
    editions.base_path,
    editions.title,
    FALSE AS is_part,
    CAST(NULL AS INT64) AS part_index,
    CAST(NULL AS STRING) AS part_slug,
    CAST(NULL AS STRING) AS part_title,
    ARRAY_TO_STRING([
      CASE
        WHEN JSON_TYPE(JSON_QUERY(editions.details, '$.body')) = 'array'
          THEN markup_from_json_array(JSON_QUERY(editions.details, '$.body'))
        WHEN JSON_TYPE(JSON_QUERY(editions.details, '$.body')) = 'string'
          THEN JSON_VALUE(editions.details, '$.body')
        ELSE CAST(NULL AS STRING)
      END,
      markup_from_json_array(JSON_QUERY(editions.details, '$.introduction')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.information')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.need_to_know')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.introductory_paragraph')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.licence_overview')),
      JSON_VALUE(editions.details, '$.start_button_text'),
      JSON_VALUE(editions.details, '$.will_continue_on'),
      markup_from_json_array(JSON_QUERY(editions.details, '$.more_information')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.what_you_need_to_know')),
      markup_from_json_array(JSON_QUERY(editions.details, '$.other_ways_to_apply')),
      JSON_VALUE(editions.details, '$.cancellation_reason'),
      ARRAY_TO_STRING(json_value_array(editions.details, '$.hidden_search_terms'), "\n"),
      JSON_VALUE(editions.details, '$.mission_statement'),
      JSON_VALUE(editions.details, '$.access_and_opening_times'),
      JSON_VALUE(editions.details, '$.born'),
      JSON_VALUE(editions.details, '$.died'),
      JSON_VALUE(editions.details, '$.major_acts'),
      JSON_VALUE(editions.details, '$.isbn')
    ], "\n\n") AS govspeak -- it doesn't matter that some of this is already HTML
  FROM editions
  INNER JOIN schema_map USING (schema_name)
  WHERE schema_map.govspeak_location = 'general'
),

-- step-by-step pages, which aren't necessarily rendered to HTML in the
-- `details.body` field.
step_by_step_nav AS (
  SELECT
    editions.id AS edition_id,
    editions.document_id,
    editions.schema_name,
    editions.base_path,
    editions.title,
    FALSE AS is_part,
    CAST(NULL AS INT64) AS part_index,
    CAST(NULL AS STRING) AS part_slug,
    CAST(NULL AS STRING) AS part_title,
    ARRAY_TO_STRING([
      markup_from_json_array(JSON_QUERY(editions.details, '$.step_by_step_nav.introduction')),
      JSON_VALUE(editions.details, '$.step_by_step_nav.introduction'),
      extractStepContents(JSON_QUERY(details, '$.step_by_step_nav.steps'))
    ], "\n") AS steps
  FROM editions
  INNER JOIN schema_map USING (schema_name)
  WHERE schema_map.govspeak_location = 'step_by_step_nav'
),

-- govspeak and HTML content of document types that have content in the details.parts array
parts AS (
  SELECT
    editions.id AS edition_id,
    editions.document_id,
    editions.schema_name,
    editions.base_path,
    editions.title,
    part_index, -- zero-based
    STRING(JSON_QUERY(part, '$.slug')) AS part_slug,
    STRING(JSON_QUERY(part, '$.title')) AS part_title,
    markup_from_json_array(JSON_QUERY(part, '$.body')) AS govspeak
  FROM editions
  INNER JOIN schema_map USING (schema_name)
  CROSS JOIN UNNEST(JSON_QUERY_ARRAY(editions.details, '$.parts')) AS part WITH OFFSET AS part_index
  WHERE schema_map.govspeak_location = 'part'
),

-- The first part of each document is available at two URLs: with and without
-- its slug. So duplicate the first part without its slug.
first_parts AS (
  SELECT
    edition_id,
    document_id,
    schema_name,
    base_path,
    title,
    FALSE AS is_part,
    part_index, -- The part that this record is derived from
    CAST(NULL AS STRING) AS part_slug,
    CAST(NULL AS STRING) AS part_title,
    govspeak
  FROM parts
  WHERE part_index = 0
),
-- Make parts like pages in their own right (concatenating the base_path and slug),
-- but leave enough metadata to be able to deconstruct them back to a true part.
all_parts AS (
  SELECT
    edition_id,
    document_id,
    schema_name,
    CONCAT(base_path, '/', part_slug) AS base_path,
    CONCAT(title, ': ', part_title) AS title,
    TRUE AS is_part,
    part_index, -- This being non-null isn't sufficient to identify parts
    part_slug, -- This being non-null is sufficient to identify parts
    part_title,
    govspeak
  FROM parts
),

combined AS (
  SELECT * FROM general
  UNION ALL SELECT * FROM step_by_step_nav

  -- Only the first part of each guide/travel_advice document, using only the base_path
  UNION ALL SELECT * FROM first_parts
  -- Every part of each guide/travel_advice document, concatenating the base_path and the slug
  UNION ALL SELECT * FROM all_parts
),

rendered AS (
  SELECT *,
    JSON_VALUE(`${project_id}.functions.govspeak_to_html`(govspeak), '$.html') AS html
  FROM combined
),

extracts AS (
  SELECT
    *,
    `${project_id}.functions.html_to_text`(html) AS text,
    `${project_id}.functions.parse_html`(html, 'https://www.gov.uk' || base_path) AS extracted_content
  FROM rendered
)

SELECT
  * EXCEPT(extracted_content),
  ARRAY(
    SELECT
      STRUCT(
        line_number + 1 AS line_number,
        line
      )
    FROM UNNEST(SPLIT(text, "\n")) AS line WITH OFFSET AS line_number
  ) AS lines,
  `${project_id}.functions.dedup`(
    ARRAY(
      SELECT
        STRUCT(
          JSON_EXTRACT_SCALAR(link, "$.link_url") AS url,
          JSON_EXTRACT_SCALAR(link, "$.link_url_bare") AS url_bare,
          JSON_EXTRACT_SCALAR(link, "$.link_text")
        )
      FROM UNNEST(JSON_EXTRACT_ARRAY(extracted_content, "$.hyperlinks")) AS link
    )
  ) AS hyperlinks,
  `${project_id}.functions.dedup`(
    ARRAY(
      SELECT
        STRUCT(
          JSON_EXTRACT_SCALAR(abbreviation, "$.title") AS title, -- expansion
          JSON_EXTRACT_SCALAR(abbreviation, "$.text") AS text    -- abbreviation
        )
      FROM UNNEST(JSON_EXTRACT_ARRAY(extracted_content, "$.abbreviations")) AS abbreviation
    )
  ) AS abbreviations,
  `${project_id}.functions.dedup`(
    ARRAY(
      SELECT
        STRUCT(
          JSON_EXTRACT_SCALAR(single_table, "$.html") AS html
        )
      FROM UNNEST(JSON_EXTRACT_ARRAY(extracted_content, "$.tables")) AS single_table
    )
  ) AS tables,
  `${project_id}.functions.dedup`(
    ARRAY(
      SELECT
        STRUCT(
          JSON_EXTRACT_SCALAR(image, "$.src") AS src,
          JSON_EXTRACT_SCALAR(image, "$.alt") AS alt
        )
      FROM UNNEST(JSON_EXTRACT_ARRAY(extracted_content, "$.images")) AS image
    )
  ) AS images
FROM extracts
;

-- Delete rows from the public.content table where a newer edition of the same
-- document is now available.  The newer edition might be private, so use the
-- private editions as the source of the merge.
MERGE INTO
public.content AS target
USING private.publishing_api_editions_new_current AS source
ON source.document_id = target.document_id
-- Sometimes an edition_id is reused, e.g. if it has been used initially by a
-- test in a non-production environment (which is where GovGraph gets its data,
-- as of 2025-05), and then used again for real in production.
OR source.id = target.edition_id
WHEN matched THEN DELETE
;

-- Insert the content of new editions into the public.content table.
INSERT INTO public.content
SELECT * FROM public.content_new
;

END
