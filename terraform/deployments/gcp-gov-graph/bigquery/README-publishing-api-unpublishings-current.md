# `publishing-api-unpublishings-current.sql`

This query maintains a table of one record per unpublished edition, but only for editions that have been unpublished in a way that means it still exists in some form on the GOV.UK website and in the Content API.

## Source: `publishing-api.unpublishings`

The source data is from the Publishing API database, which contains a record of
every version of every document that has ever been published or drafted (at
least since the Publishing API was implemented).

## Target `public.publishing_api_unpublishings_current`

The target is a table of records of what editions have been unpublished, and how. When an edition is unpublisshed with type `vanish` or `substitute`, there is no publicly available evidence of that edition's previous existence, so unpublishings of those types are omitted from the target table.
