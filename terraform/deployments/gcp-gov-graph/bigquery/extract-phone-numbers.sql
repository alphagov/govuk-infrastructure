-- Uncomment at the top and bottom of this file to manually define the function
-- outside of terraform.

-- CREATE FUNCTION
--   functions.extract_phone_numbers_2(text STRING)
--   RETURNS ARRAY<STRUCT<startsAt INT64,
--   endsAt INT64,
--   test STRING,
--   country STRING,
--   countryCallingCode STRING,
--   nationalNumber STRING,
--   number STRING>> AS (
    (
    WITH
      nested AS (
      SELECT
        JSON_EXTRACT_ARRAY(`${project_id}.functions.libphonenumber_find_phone_numbers_in_text`(text), "$") AS numbers ),
      unnested AS (
      SELECT
        CAST(JSON_EXTRACT_SCALAR(number, "$.startsAt") AS INT64) AS startsAt,
        CAST(JSON_EXTRACT_SCALAR(number, "$.endsAt") AS INT64) AS endsAt,
        JSON_EXTRACT_SCALAR(number, "$.text") AS text,
        JSON_EXTRACT_SCALAR(number, "$.number.country") AS country,
        JSON_EXTRACT_SCALAR(number, "$.number.countryCallingCode") AS countryCallingCode,
        JSON_EXTRACT_SCALAR(number, "$.number.nationalNumber") AS nationalNumber,
        JSON_EXTRACT_SCALAR(number, "$.number.number") AS number
      FROM
        nested,
        UNNEST(numbers) AS number )
    SELECT
      ARRAY_AGG(STRUCT(startsAt AS starts_at,
          endsAt AS ends_at,
          text AS text,
          country AS country,
          countryCallingCode AS country_calling_code,
          nationalNumber AS national_number,
          number AS number)) AS numbers
    FROM
      unnested )
-- );
