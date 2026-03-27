# `taxonomy.sql`

This query maintains a table of one record per taxon that is currently published on the GOV.UK website and in the Content API.  The ancestors of each taxon (via direct ancestry or via association, or both) are given in columns of an `ARRAY` data type.

## Sources

* `public.publishing_api_editions_current`
* `public.publishing_api_links_current`

## Target `public.publishing_api_unpublishings_current`

## Context

A taxon is a content item like anything else, which has a document (always in the `en` locale), and an edition.  The hierarchy is expressed via links in the table `public.publishing_api_links_current`.  This query recurses the hierarchy to create a table that is easier to use.  Users of the table shouldn't have to do any recursion.
