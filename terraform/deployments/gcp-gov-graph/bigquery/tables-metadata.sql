-- For alerting and debugging.
--
-- For each table in the project, its modified date and row count, sorted
-- ascending.
WITH all_objects AS (
  SELECT * FROM content.__TABLES__
  UNION ALL
  SELECT * FROM private.__TABLES__
  UNION ALL
  SELECT * FROM public.__TABLES__
  UNION ALL
  SELECT * FROM publishing_api.__TABLES__
  UNION ALL
  SELECT * FROM support_api.__TABLES__
  UNION ALL
  SELECT * FROM search.__TABLES__
  UNION ALL
  SELECT * FROM asset_manager.__TABLES__
  UNION ALL
  SELECT * FROM publisher.__TABLES__
)
,
-- tables which  do not need to checked should be listed here. For example, intermediate tables which may not always contain new daily data.
tables_that_can_be_empty AS (
  SELECT 'private' AS dataset_id, 'publishing_api_editions_new_current' AS table_id
  UNION ALL
  SELECT 'public', 'publishing_api_editions_new_current'
  UNION ALL
  SELECT 'public', 'content_new'
)
-- The objects have to be filtered on type = 1. This will only include native tables.
-- The column `last_modified_time` can only be relied upon to detect changes in rows of native tables.
-- Other objects such as views and external tables have different semantics which would need a different approach.
,
tables AS (
  SELECT
    all_objects.*,
    tables_that_can_be_empty.table_id IS NULL AS must_be_populated
  FROM all_objects
  LEFT OUTER JOIN tables_that_can_be_empty
  ON tables_that_can_be_empty.dataset_id = all_objects.dataset_id
    AND tables_that_can_be_empty.table_id = all_objects.table_id
  WHERE all_objects.type = 1
)
SELECT
  dataset_id,
  table_id,
  TIMESTAMP_MILLIS(last_modified_time) AS last_modified,
  row_count,
  must_be_populated
FROM tables
ORDER BY
  last_modified,
  row_count;
