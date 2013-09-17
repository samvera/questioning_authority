Questioning Authority
=====================

Question your authorities

# Routes

### Autocomplete for a given vocabulary

    GET /:vocab/search?q="abc"

parameters:

    q = the initial segement to match. If not given, q='' is assumed, which should match every term.
    n = the number of matches to return. If not given, assumed to be 20. 

returns a json object having the format

    [
        {id = "subject_id_1", label = "First labels"},
        {id = "subject_id_2", label = "Printing labels"}
    ]

### Get info for a given term

    GET /:vocab/term/:id

### Get general information for a vocabulary

    GET /:vocab/about

* return synonyms
* return hierarchy

Authority Sources information
=============================

### Library of Congress (example uses language):

Base url: http://id.loc.gov/search/

Example search (html): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2

Example search (json): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2&format=json