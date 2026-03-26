# Queries for batch execution and user-defined functions

This directory contains queries that are executed as part of a daily batch, or
that define custom functions to be used in other queries.

## `publishing-api-editions-current.sql`

Maintains a table of one record per document that currently appears on the
website.

See [`README-publishing-api-editions-current.sql`](README-publishing-api-editions-current.sql).

## `publishing-api-links-current.sql`

Maintains a table of one record per link between documents that currently appear on the website.

See [`README-publishing-api-links-current.sql`](README-publishing-api-links-current.sql).

## `publishing-api-unpublishings-current.sql`

Maintains a table of one record per document that no longer appears on the website, but whose previous existinece is still publicly known on the website or in the Content API.

See [`README-publishing-api-unpublishings-current.sql`](README-publishing-api-unpublishings-current.sql).

## `extract-markup-from-editions.sql`

Maintains a table of one record per document that currently appears on the
website.

See [`README-extract-markup-from-editions.sql`](README-extract-markup-from-editions.sql).
