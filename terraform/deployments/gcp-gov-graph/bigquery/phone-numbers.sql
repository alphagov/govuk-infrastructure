-- Phone numbers from contact documents and general page content, detected by
-- GovNer (entities) and libphonenumber, and standardised by libphonenumber.
TRUNCATE TABLE
  public.phone_numbers;
INSERT INTO
  public.phone_numbers
WITH
  -- Phone numbers from contact documents.
  contacts AS (
  SELECT
    contact_phone_numbers.edition_id,
    NULL AS part_index,
    number.original_number,
    number.standardised_number
  FROM
    `public.contact_phone_numbers` AS contact_phone_numbers,
    UNNEST(numbers) AS number ),
  -- Only those entities that are phone numbers, to avoid unnecessary calls to the
  -- libphonenumber function, which is slow.
  phone_entities AS (
  SELECT
    DISTINCT url,
    name AS number,
  FROM
    `cpto-content-metadata.named_entities.named_entities_all`
  WHERE
    type = "PHONE" ),
  -- Get the corresponding edition_id for each entity
  phone_entities_editions AS (
  SELECT
    DISTINCT editions.id AS edition_id,
    phone_entities.number
  FROM
    phone_entities
  INNER JOIN
    public.publishing_api_editions_current AS editions
  ON
    "https://www.gov.uk" || editions.base_path = phone_entities.url ),
  -- Phone numbers in page content, detected by GovNer (entities).
  entities AS (
  SELECT
    phone_entities_editions.edition_id,
    NULL AS part_index,
    phone_entities_editions.number AS original_number,
    extracted_numbers.number AS standardised_number
  FROM
    phone_entities_editions,
    UNNEST(`${project_id}.functions.extract_phone_numbers`(number)) AS extracted_numbers ),
  -- Unique lines of page content, to avoid unnecessary calls to the
  -- libphonenumber function, which is slow.
  lines AS (
  SELECT
    DISTINCT edition_id,
    part_index,
    line.line
  FROM
    public.content,
    UNNEST(lines) AS line ),
  -- Phone numbers in page content, detected by libphonenumber
  content AS (
  SELECT
    lines.edition_id,
    lines.part_index,
    extracted_numbers.text AS original_number,
    extracted_numbers.number AS standardised_number
  FROM
    lines,
    UNNEST(`${project_id}.functions.extract_phone_numbers`(line)) AS extracted_numbers ),
  -- Combine them all and remove duplicates.
  combined AS (
  SELECT
    *
  FROM
    contacts
  UNION ALL
  SELECT
    *
  FROM
    entities
  UNION ALL
  SELECT
    *
  FROM
    content ),
  distinct_numbers AS (
  SELECT
    DISTINCT edition_id,
    part_index,
    original_number,
    standardised_number
  FROM
    combined )
SELECT
  edition_id,
  part_index,
  ARRAY_AGG(STRUCT(original_number,
      standardised_number)) AS phone_numbers
FROM
  distinct_numbers
GROUP BY
  edition_id,
  part_index ;
