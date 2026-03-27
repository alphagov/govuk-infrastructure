-- Maintains a table `public.department_analytics_profle` of Google Analytics
-- IDs of certain organisations.
TRUNCATE TABLE public.department_analytics_profile;
INSERT INTO public.department_analytics_profile
SELECT
  editions.id,
  JSON_value(details, "$.department_analytics_profile") AS department_analytics_profile
FROM public.publishing_api_editions_current AS editions
WHERE JSON_value(details, "$.department_analytics_profile") IS NOT NULL
  AND JSON_value(details, "$.department_analytics_profile") <> ""
;
