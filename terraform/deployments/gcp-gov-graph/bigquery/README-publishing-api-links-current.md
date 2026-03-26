# `publishing-api-links-current.sql`

This query maintains a table of one record per link between editions that currently appear on the GOV.UK website and Content API.

## Sources

* `publishing-api.links`
* `publishing-api.link_sets`
* `public.publishing_api_editions_current`

## Target `public.publishing_api_links_current`

The Publishing API's data model of links is complicated by having to handle links to specific editions, which might have been superseded.  This query and table simplify the model, because it only has to link to current editions.  In the target table, every link is associated with a specific source edition and target edition, rather than that having to be looked up via a `content_id`.
