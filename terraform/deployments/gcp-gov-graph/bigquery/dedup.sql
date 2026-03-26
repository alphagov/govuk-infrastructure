-- Uncomment at the top and bottom of this file to manually define the function
-- outside of terraform.

-- A function like DISTINCT but works on an array of any type, including STRUCT
-- https://stackoverflow.com/a/55778635

-- CREATE FUNCTION
--   functions.dedup(val ANY TYPE)
--   AS (
  (
    SELECT ARRAY_AGG(t)
    FROM (SELECT DISTINCT * FROM UNNEST(val) v) t
  )
-- );
