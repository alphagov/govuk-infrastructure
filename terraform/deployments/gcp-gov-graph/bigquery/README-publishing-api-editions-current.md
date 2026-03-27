# `publishing-api-editions-current.sql`

This query maintains a table of one record per document as it currently appears
on the GOV.UK website and in the Content API.

## Source: `publishing-api.editions`

The source data is from the Publishing API database, which contains a record of
every version of every document that has ever been published or drafted (at
least since the Publishing API was implemented).

## Target `public.publishing-api-editions-current`

The target is a table of editions of documents as they currently appear on the
GOV.UK website and in the Content API.  Because this information is already
publicly available, the table is in the `public` dataset.

## Context

An edition can appear on the GOV.UK website and in the Content API if there is a
URL where that particular document is available in its own right, or if the
document is rendered as part of another document that has a URL, such as a
`person` rendered as part of an `organisation`.

### Editions vs documents

A "content item" (a piece of content) is purely conceptual. It doesn't
necessarily map to a particular web page. It may represent an organisation, a
person, a role, a set of contact details such as addresses and telephone
numbers.  It also isn't versioned.  In the publishing database, it is
represented only by its `content_id`.  It doesn't even have a 'type'.  There is no
`content` table, because its only column would be its primary key: `content_id`.

Each content item (unique key: `content_id`) has one or more "documents" (unique
key: `content_id`, `locale`).  A piece of content has at most one document per
locale.

One document has one or more "editions" (key: `document_id`, `updated_at`).  The
edition has a `document_type`, which describes what the edition's content
item represents.  It is an odd name, and an odd place to record it.  The fact
that the `document_type` belongs to the edition rather than to either the
document or the content item means that the schema doesn't guarantee any of
the following:

* that every edition of the same content item has the same `document_type`
* that every edition of the same document has the same `document_type`
* that every _current_ edition of the same content item or document has the
same `document_type`

We must allow for the `document_type` to vary between:

* different editions of a document, which means the `document_type` of an
edition can change over time
* most-recent editions of each document of a given content item, which means
that different translations of the same content item might have different
`document_type`s.

A typical example is a consultation, which is represented by a different
`document_type` in each part of its lifecycle, such as the one whose
`content_id` is `9884ebdc-8135-4d19-909e-94c744dd7798`.

1. `coming_soon`
2. `consultation`
3. `open_consultation`
4. `closed_consultation`
5. `consultation_outcome`

Perhaps it would have made more sense to vary the `schema_name`, rather than
the `document_type`.  Never mind.

```sql
-- Content items that have had more than one document type
WITH
  doc_types AS (
  SELECT
    DISTINCT content_id,
    locale,
    document_type
  FROM
    publishing_api.editions
  INNER JOIN
    publishing_api.documents
  ON
    documents.id = editions.document_id )
SELECT
  content_id,
  locale,
  COUNT(*) AS n_document_types
FROM
  doc_types
GROUP BY
  content_id,
  locale
HAVING
  COUNT(*) > 1
ORDER BY
  COUNT(*) DESC
LIMIT
  10 ;
```

|            `content_id`              | `locale` | `n_document_types` |
|--------------------------------------|----------|--------------------|
| 0000600f-265d-46b9-9deb-016405b7f369 | en       |                  3 |
| 000061c8-671f-4d51-8e77-16431e827575 | en       |                  2 |
| 0001f1a9-3285-4897-baa9-f6663aeb1e8a | en       |                  2 |
| 00022740-0ba7-4fd0-8ca8-f0c3d6156fec | en       |                  2 |
| 000227a8-f0d2-417d-8ce4-27a18d62d442 | en       |                  2 |
| 00026064-784c-4eca-b24b-0f4b092a329a | en       |                  2 |
| 0002b328-cf71-4271-8360-e0bcc4b6f8fb | en       |                  2 |
| 000308e8-c04c-4416-89ac-f1d2442f77b6 | en       |                  2 |
| 00037b70-5b08-44c2-bf0a-fa8eb636a60b | en       |                  2 |
| 000601a7-19b7-5e92-984a-c2c87ab4d704 | en       |                  2 |

```sql
SELECT
  locale,
  editions.updated_at,
  document_type,
  schema_name
FROM
  publishing_api.editions
INNER JOIN
  publishing_api.documents
ON
  documents.id = editions.document_id
WHERE
  content_id = '9884ebdc-8135-4d19-909e-94c744dd7798'
ORDER BY
  locale,
  editions.updated_at ;
```

```sql
-- Current edition of each document
CREATE TABLE
  test.editions_current AS (
  SELECT
    documents.content_id,
    documents.locale,
    editions.*
  FROM
    publishing_api.editions
  INNER JOIN
    publishing_api.documents
  ON
    documents.id = editions.document_id
  WHERE
    state <> 'draft' QUALIFY ROW_NUMBER() OVER (PARTITION BY content_id, locale ORDER BY updated_at DESC) = 1 );
```

```sql
-- Content items that currently have documents whose editions are different
-- document_types.
WITH
  doc_types AS (
  SELECT
    DISTINCT content_id,
    document_type
  FROM
    test.editions_current )
SELECT
  content_id,
  COUNT(*) AS n_document_types
FROM
  doc_types
GROUP BY
  content_id
HAVING
  COUNT(*) > 1
ORDER BY
  COUNT(*) DESC
LIMIT
  10 ;
```

|             `content_id`             | `n_document_types` |
|--------------------------------------|--------------------|
| 004a6456-8fc6-4321-b60b-ca436a8486de |                  2 |
| 5f5c20e9-7631-11e4-a3cb-005056011aef |                  2 |
| 5f56a533-7631-11e4-a3cb-005056011aef |                  2 |
| 5d2b66f9-7631-11e4-a3cb-005056011aef |                  2 |
| 54134a63-e693-4950-9f39-23d03ca6acf6 |                  2 |
| 6055de47-7631-11e4-a3cb-005056011aef |                  2 |
| 87646ce8-ef69-4014-980a-c63b8ccde645 |                  2 |
| 5fa5bc26-7631-11e4-a3cb-005056011aef |                  2 |
| 5f568fb2-7631-11e4-a3cb-005056011aef |                  2 |
| 944c3cde-0915-4dda-bcdb-729eb413d7cd |                  2 |

```sql
SELECT
  locale,
  document_type,
  updated_at
FROM
  test.editions_current
WHERE
  content_id = '004a6456-8fc6-4321-b60b-ca436a8486de' ;
```

| `locale` | `document_type` |         `updated_at`       |
|----------|-----------------|----------------------------|
| cy       | placeholder     | 2017-02-02 14:34:56.063013 |
| en       | foi_release     | 2022-05-09 11:03:34.143869 |

```sql
-- Editions that are currently online with their own URL
CREATE TABLE
  test.editions_online AS (
  SELECT
    editions_current.*
  FROM
    test.editions_current
  LEFT JOIN
    publishing_api.unpublishings
  ON
    unpublishings.edition_id = editions_current.id
  WHERE
    content_store = 'live'
    AND state <> 'superseded'
    AND COALESCE(unpublishings.type <> 'vanish', TRUE)
    AND ( LEFT(schema_name, 11) <> 'placeholder'
      OR (
        -- schema_name must be checked again because short-circuit evaluation
        -- isn't available in this clause.
        LEFT(schema_name, 11) = 'placeholder'
        AND COALESCE(unpublishings.type IN ('gone',
            'redirect'), FALSE) ) ) ) ;
```

```sql
-- Online content items that currently have documents whose editions are
-- different document_types.
WITH
  doc_types AS (
  SELECT
    DISTINCT content_id,
    document_type
  FROM
    test.editions_online )
SELECT
  content_id,
  COUNT(*) AS n_document_types
FROM
  doc_types
GROUP BY
  content_id
HAVING
  COUNT(*) > 1
ORDER BY
  COUNT(*) DESC
LIMIT
  10 ;
```

|             `content_id`             | `n_document_types` |
|--------------------------------------|--------------------|
| 5e2cef4d-7631-11e4-a3cb-005056011aef |                  2 |
| 5fa5bc26-7631-11e4-a3cb-005056011aef |                  2 |
| 5f568fb2-7631-11e4-a3cb-005056011aef |                  2 |
| 5f56a533-7631-11e4-a3cb-005056011aef |                  2 |
| 54134a63-e693-4950-9f39-23d03ca6acf6 |                  2 |
| 6055de47-7631-11e4-a3cb-005056011aef |                  2 |
| 87646ce8-ef69-4014-980a-c63b8ccde645 |                  2 |
| 6031bb8f-7631-11e4-a3cb-005056011aef |                  2 |
| 8508f8c9-38d3-41d4-a274-8b4cfb7de61c |                  2 |
| 944c3cde-0915-4dda-bcdb-729eb413d7cd |                  2 |

```sql
SELECT
  locale,
  document_type,
  updated_at,
  base_path
FROM
  test.editions_online
WHERE
  content_id = '5e2cef4d-7631-11e4-a3cb-005056011aef' ;
```

| `locale` |  `document_type`   |        `updated_at`        |
|----------|--------------------|----------------------------|
| en       | statutory_guidance | 2023-09-29 10:09:26.803491 |
| cy       | policy_paper       | 2021-01-28 09:32:20.036697 |

## Implementation

It would be expensive to maintain this table in a straightforward batch query,
because the source table is big. Costs are lowered by:

* Partitioning large tables on `updated_at`.
* Subsetting for only those editions that haven't been seen yet.
* Wrapping several queries in a single transaction.

We tell which editions are new since the last update by inspecting the field
`updated_at`, rather than the field `id`, which isn't guaranteed to be
sequential, and often isn't.

Unfortunately, `updated_at` isn't unique.  See the following query.

```sql
SELECT
  updated_at,
  COUNT(*) AS n,
  ARRAY_AGG(id) AS ids
FROM
  `publishing_api.editions`
GROUP BY
  updated_at
HAVING
  n > 1
ORDER BY
  updated_at desc ;
```

It might be possible for multiple rows of the editions table to have the same
`updated_at` time, but not be inserted in the same transaction, which means that
they might also not appear in the same nightly backup file.  In case this
happens, we always delete the records in the `editions_current` and
`editions_online` tables that have the most recent `updated_at` date. Then we
can safely treat all records on or after that date as new ones.
