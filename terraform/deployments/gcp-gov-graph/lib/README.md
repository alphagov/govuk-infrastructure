# Third-Party Libraries

Code from elsewhere that is deployed here.

## Libphonenumber

https://github.com/google/libphonenumber

From their README:

> Google's common Java, C++ and JavaScript library for parsing, formatting, and validating international phone numbers. The Java version is optimized for running on smartphones, and is used by the Android framework since 4.0 (Ice Cream Sandwich).

We use this to detect phone numbers in plain text, and to standardise the
numbers to make them searchable.
[GovSearch](https://github.com/alphagov/govuk-knowledge-graph-search) uses the
same library to standardise phone numbers that users input into the search box.
It can then search for matches between standardised numbers, rather than having
to handle meaningless differences between, for example, "01234 567 890" and
"+441234 567890", which are different ways to write the same number.

We also detect phone numbers in plain text by using the table
`cpto-content-metadata.named_entities.named_entities_all`, which is derived by
[named entity recognition](https://github.com/alphagov/govuk-content-metadata)
from tables created by this repository, such as `content.lines`.

We don't use Google's own javascript implementation of libphonenumber, because it
isn't easily deployed, and can't find phone numbers in text.  Instead we use
https://github.com/catamphetamine/libphonenumber-js which is recommended in
Google's own README.  A disadvantage is that it doesn't support as wide a
variety of phone numbers as Google's implementation.

Note that [GovSearch](https://github.com/alphagov/govuk-knowledge-graph-search)
uses a different distribution,
https://github.com/ruimarinho/google-libphonenumber, which is a mirror of
Google's own software, but packaged for node.js.  GovSearch can use this
distribution because GovSearch doesn't need to search for numbers in text,
because the user may only input one at a time.  Its advantage is that it
supports all the phone numbers that Google supports.
