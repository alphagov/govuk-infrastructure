-- Call a sequence of routines that refresh tables in the `search` dataset for
-- the GovSearch app.

CALL search.document_type();
CALL search.government();
CALL search.locale();
CALL search.organisation();
CALL search.person();
CALL search.taxon();
CALL search.page();
CALL search.publishing_app();
