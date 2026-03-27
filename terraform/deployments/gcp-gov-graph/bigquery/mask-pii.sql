-- Uncomment at the top and bottom of this file to manually define the function
-- outside of terraform.

-- CREATE FUNCTION
--   functions.mask_pii2(text STRING)
--   RETURNS STRING AS (
  (
    SELECT `${project_id}.functions.data_loss_prevention`(
      -- TRUNCATE the input text to a certain number of bytes. The number is
      -- hand-picked, and varies according to the size of the other parameters
      -- passed into the data_loss_prevention function. The formula to calculate
      -- the number of bytes used by those parameters is obscure, so trial and
      -- error can be used by substituting `text` with `REPEAT("a", 550000)` to
      -- create a 550000 byte string, and changing its size until a maximum size
      -- is found that doesn't cause an error in the data_loss_prevention
      -- function.
      SAFE_CONVERT_BYTES_TO_STRING(LEFT(CAST(text AS BYTES), 523429)),
      -- inspect_config. Unfortunately this has to be on one line.
      PARSE_JSON(' { "info_types": [ { "name": "DATE_OF_BIRTH" }, { "name": "EMAIL_ADDRESS" }, { "name": "PASSPORT" }, { "name": "PERSON_NAME" }, { "name": "PHONE_NUMBER" }, { "name": "STREET_ADDRESS" }, { "name": "UK_NATIONAL_INSURANCE_NUMBER" }, { "name": "UK_PASSPORT" }, { "name": "CREDIT_CARD_NUMBER" }, { "name": "IBAN_CODE" }, { "name": "IP_ADDRESS" }, { "name": "MEDICAL_TERM" }, { "name": "VEHICLE_IDENTIFICATION_NUMBER" }, { "name": "SCOTLAND_COMMUNITY_HEALTH_INDEX_NUMBER" }, { "name": "UK_DRIVERS_LICENSE_NUMBER" }, { "name": "UK_NATIONAL_HEALTH_SERVICE_NUMBER" }, { "name": "UK_TAXPAYER_REFERENCE" }, { "name": "SWIFT_CODE" } ], "include_quote": true } '),
      -- deidentify_config. Unfortunately this has to be on one line.
      PARSE_JSON(' { "info_type_transformations": { "transformations": [ { "info_types": [ { "name": "DATE_OF_BIRTH" }, { "name": "EMAIL_ADDRESS" }, { "name": "PASSPORT" }, { "name": "PERSON_NAME" }, { "name": "PHONE_NUMBER" }, { "name": "STREET_ADDRESS" }, { "name": "UK_NATIONAL_INSURANCE_NUMBER" }, { "name": "UK_PASSPORT" }, { "name": "CREDIT_CARD_NUMBER" }, { "name": "IBAN_CODE" }, { "name": "IP_ADDRESS" }, { "name": "MEDICAL_TERM" }, { "name": "VEHICLE_IDENTIFICATION_NUMBER" }, { "name": "SCOTLAND_COMMUNITY_HEALTH_INDEX_NUMBER" }, { "name": "UK_DRIVERS_LICENSE_NUMBER" }, { "name": "UK_NATIONAL_HEALTH_SERVICE_NUMBER" }, { "name": "UK_TAXPAYER_REFERENCE" }, { "name": "SWIFT_CODE" } ], "primitive_transformation": { "replace_with_info_type_config": {} } } ] } } ')
    )
  )
-- );
