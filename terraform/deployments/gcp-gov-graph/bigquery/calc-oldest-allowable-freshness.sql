CASE
  -- BigQuery Days: 1=Sunday, 2=Monday, 3=Tuesday... 7=Saturday
  WHEN EXTRACT(DAYOFWEEK FROM timestamp) = 7 THEN TIMESTAMP_ADD(timestamp, INTERVAL - 50 HOUR) -- Saturday (48h + 2h tolerance)
  WHEN EXTRACT(DAYOFWEEK FROM timestamp) = 1 THEN TIMESTAMP_ADD(timestamp, INTERVAL - 74 HOUR) -- Sunday (72h + 2h tolerance)
  WHEN EXTRACT(DAYOFWEEK FROM timestamp) = 2 THEN TIMESTAMP_ADD(timestamp, INTERVAL - 74 HOUR) -- Monday (72h + 2h tolerance)
  ELSE TIMESTAMP_ADD(timestamp, INTERVAL - 26 HOUR) -- (24h + 2h tolerance)
END
