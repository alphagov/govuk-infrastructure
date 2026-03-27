-- A table of unique taxon titles, for a drop-down menu.
--
-- Taxonomy titles aren't unique. Most of them can be disambiguated by using
-- their internal_name instead, but often the internal_name isn't suitable for
-- use elsewhere than a publishing app. Titles seem to be duplicated when they
-- relate to a particular country, such as "Help and services around the
-- world", the internal name of which is "Help and services around the world
-- (Algeria)". The GovSearch app probably shouldn't list every country's
-- version of that taxon, so it lists the generic version. Those taxons
-- usually have an associated_taxons link to "UK help and services in Algeria"
-- (or whichever country) anyway, so if users need to be specific then they
-- can filter by that taxon.
TRUNCATE TABLE search.taxon;
INSERT INTO search.taxon
SELECT DISTINCT editions.title
FROM public.taxonomy
INNER JOIN public.publishing_api_editions_current AS editions
  ON editions.id = taxonomy.edition_id
