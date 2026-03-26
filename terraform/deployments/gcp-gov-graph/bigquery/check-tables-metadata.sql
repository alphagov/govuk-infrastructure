-- Fail with an error message when certain conditions in the
-- `test.tables_metadata` view are met.
-- Errors will be picked up in the logs, generating an alert.
SELECT
  *,
  CASE
    -- Raise an alert for tables that have zero rows
    WHEN row_count = 0
      AND must_be_populated
      -- And that aren't likely to be still being refreshed.
      -- Annoyingly, it isn't possible to TRUNCATE in the same transaction, so
      -- tables will briefly be empty until they are repopulated.
      AND last_modified < TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL - 10 MINUTE)
      THEN ERROR(CONCAT('${alerts_error_message_no_data} `', dataset_id, ".", table_id, "` last updated at ", last_modified, "."))
    -- Raise an alert for tables that haven't been updated as expected
    WHEN last_modified < functions.calc_oldest_allowable_freshness(CURRENT_TIMESTAMP())
      THEN ERROR(CONCAT('${alerts_error_message_old_data} `', dataset_id, ".", table_id, "` last updated at ", last_modified, "."))
    ELSE CONCAT('Table `', dataset_id, ".", table_id, "` has ", row_count, " rows, last updated at ", last_modified, ".")
  END AS result
FROM `test.tables_metadata`;
