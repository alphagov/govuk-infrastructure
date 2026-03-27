-- A table of phone numbers from documents of schema 'contact'
-- One row per number detected among the given numbers
-- https://github.com/alphagov/publishing-api/blob/bd129e7344e4fe0d488f515c05ed937a21a61a6e/content_schemas/dist/formats/contact/publisher_v2/schema.json
TRUNCATE TABLE public.contact_phone_numbers;
INSERT INTO public.contact_phone_numbers
WITH
contacts AS (
  SELECT
    id,
    JSON_VALUE(phone_number, '$.title') AS title,
    JSON_VALUE(phone_number, '$.description') AS description,
    JSON_VALUE(phone_number, '$.open_hours') AS open_hours,
    JSON_VALUE(phone_number, '$.best_time_to_call') AS best_time_to_call,
    JSON_VALUE(phone_number, '$.number') AS number,
    JSON_VALUE(phone_number, '$.fax') AS fax,
    JSON_VALUE(phone_number, '$.textphone') AS textphone,
    JSON_VALUE(phone_number, '$.international_phone') AS international_phone
  FROM
    public.publishing_api_editions_current,
    UNNEST(JSON_QUERY_ARRAY(details, "$.phone_numbers")) AS phone_number
  WHERE schema_name = 'contact'
),
numbers AS (
  SELECT
    id,
    title,
    description,
    open_hours,
    best_time_to_call,
    type,
    number
  FROM contacts
  UNPIVOT(number FOR type IN (number, fax, textphone, international_phone))
)
SELECT
  n.id AS edition_id,
  n.title,
  n.description,
  n.open_hours,
  n.best_time_to_call,
  ARRAY_AGG(STRUCT(
    n.type,
    n.number AS original_number,
    standardised_number.text AS detected_number,
    standardised_number.number AS standardised_number
  )) AS numbers
FROM
  numbers AS n,
  UNNEST(`${project_id}.functions.extract_phone_numbers`(number)) AS standardised_number
GROUP BY
  n.id,
  n.title,
  n.description,
  n.open_hours,
  n.best_time_to_call
;
