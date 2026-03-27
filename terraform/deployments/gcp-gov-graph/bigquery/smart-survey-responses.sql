-- Append new Smart Survey API results to the smart_survey.responses table.
-- Idempotent.

BEGIN

-- Delete any responses that have newer versions in the source table.
MERGE smart_survey.responses AS T
USING (
  SELECT
    record.*
  FROM
    `smart_survey.SOURCE_TABLE_NAME`,
    UNNEST(records) AS record
) AS S
ON T.id = S.id

-- The table requires filtering by the partition, but we don't want to filter in
-- case the API changes the date_started of a survey response, which could
-- create duplicates unless we always check for the existence of every response
-- ID.
AND T.date_started >= TIMESTAMP_SECONDS(0)

WHEN MATCHED THEN DELETE;

-- Insert new responses.
INSERT INTO smart_survey.responses
SELECT * FROM (
  SELECT
    record.*
  FROM
    `smart_survey.SOURCE_TABLE_NAME`,
    UNNEST(records) AS record
);

END
