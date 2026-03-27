-- Count the number of views of pages on GOV.UK as collected by GA4.
-- Includes only those pages that exist in the Publishing API and that have been
-- viewed at least six times in seven-day window.
TRUNCATE TABLE private.page_views;
INSERT INTO private.page_views
WITH
page_views AS (
  SELECT
  REGEXP_REPLACE(page_location, r'[?#].*', '') AS url,
  FROM `ga4-analytics-352613.flattened_dataset.partitioned_flattened_events`
  WHERE
    event_name = 'page_view'
    -- A seven-day window. GA4 data is often very incomplete until a couple of
    -- days after the given date, so this window is offset from the current date
    -- by a couple of days.
    AND event_date >= DATE_ADD(CURRENT_DATE(), INTERVAL - 8 DAY)
    AND event_date <= DATE_ADD(CURRENT_DATE(), INTERVAL - 2 DAY)
),
all_urls AS (
  -- The editions table includes every base_path except for parts of 'guide' and
  -- 'travel_advice' schemas.
  --
  -- The content table includes base_paths of parts of 'guide' and
  -- 'travel_advice' schemas, as well as of other pages, but only when they have
  -- any content in them.
  --
  -- So we combine the two.
  SELECT base_path FROM public.publishing_api_editions_current
  UNION DISTINCT
  SELECT base_path FROM public.content
)
SELECT
  page_views.url,
  COUNT(page_views.url) AS number_of_views
FROM page_views
INNER JOIN all_urls ON "https://www.gov.uk" || all_urls.base_path = page_views.url
GROUP BY page_views.url
HAVING number_of_views > 5
ORDER BY number_of_views DESC
;
