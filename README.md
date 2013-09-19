Questioning Authority
=====================

[![Build Status](https://travis-ci.org/projecthydra/questioning_authority.png)](https://travis-ci.org/projecthydra/questioning_authority)

Question your authorities

# Routes

### Autocomplete for a given vocabulary

    GET /:vocab/search?q="abc"

parameters:

    q = the initial segement to match. If not given, q='' is assumed, which should match every term.

returns a json object having the format

    [
        {"id" : "subject_id_1", "label" : "First labels"},
        {"id" : "subject_id_2", "label" : "Printing labels"},
        {"id" : "", "label" : "This term has no id number"},
        {"id" : "", "label" : "Neither does this"}
    ]

### Get info for a given term

    GET /:vocab/term/:id

Returns a JSON dictionary with keys varying by vocabulary. Example:

    GET /mesh/term/D000001

    response: { "id" : "D000001",
                "label" : "Calcimycin",
                "tree_numbers" : ["D03.438.221.173"],
                "synonyms" : ["A-23187", "A23187", "Antibiotic A23187", "A 23187", "A23187, Antibiotic"]
              }

Returns a 401 error if the id number does not resolve.


### Get general information for a vocabulary

    GET /:vocab/about

Returns a JSON dictionary with keys varying by vocabulary.

Authority Sources information
=============================

### Library of Congress (example uses language):

Base url: http://id.loc.gov/search/

Example search (html): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2

Example search (json): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2&format=json

Example search (json, second page): http://id.loc.gov/search/?q=a*%20cs:http://id.loc.gov/vocabulary/countries&start=21&format=json

Local Authority Files
=====================

### YAML file of terms

#### Location and Naming Convention

Local authorities are specified in YAML files, one for each sub-authority.  By default, local authority YAML files are located in config/authorities/ .  This location can be changed by editing the :local_path entry in config/authorities.yml.  Relative paths are assumed to be relative to Rails.root.

Local authority YAML files are named for the sub-authority they represent.  For example, a YAML file for the "states" sub-authority would be named states.yml.

#### Supported formats

##### List of terms

	:terms:
		- Term 1
		- Term 2
		
##### List of id and term keys and, optionally, active key

	:terms:
		- :id: id1
		  :term: Term 1
		  :active: true
		- :id: id2
		  :term: Term 2
		  :active: false
