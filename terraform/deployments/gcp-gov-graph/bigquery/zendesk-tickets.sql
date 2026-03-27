-- Append new Zendesk API tickets to the zendesk.tickets table.
-- Idempotent.

BEGIN

-- Derive a temporary table of new tickets that resembles zendesk.tickets.
CREATE TEMP TABLE _SESSION.new_tickets AS
SELECT
INT64(JSON_QUERY(result, "$.id")) AS id,
PARSE_TIMESTAMP("%Y-%m-%dT%H:%M:%SZ", JSON_VALUE(result, "$.created_at")) AS created_at,
PARSE_TIMESTAMP("%Y-%m-%dT%H:%M:%SZ", JSON_VALUE(result, "$.updated_at")) AS updated_at,
result AS ticket
FROM `zendesk.SOURCE_TABLE_NAME`
CROSS JOIN UNNEST(results) AS result;

-- Delete any tickets that have newer versions in the source table.
MERGE zendesk.tickets AS T
USING _SESSION.new_tickets AS S
ON T.id = S.id

-- The table requires filtering by the partition, but we don't want to filter in
-- case the API changes the created_at of a ticket, which could create
-- duplicates unless we always check for the existence of every response ID.
AND T.created_at >= TIMESTAMP_SECONDS(0)

WHEN MATCHED THEN DELETE;

-- Insert new tickets.
INSERT INTO zendesk.tickets
SELECT * FROM _SESSION.new_tickets;

DROP TABLE _SESSION.new_tickets;

END
