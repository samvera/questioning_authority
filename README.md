# Questioning Authority

[![Build Status](https://travis-ci.org/projecthydra/questioning_authority.png)](https://travis-ci.org/projecthydra/questioning_authority)

You should question your authorities.

## What does this do?

Provides a set of uniform RESTful routes to query any controlled vocabulary of set of authority terms.
Results are returned in JSON, to be used in the context of a Rails application.  Primary examples would
include providing auto-complete functionality via Javascript or populating a dropdown menu with a set
of terms.

## How does it work?

Authorities are defined as classes, each implementing a set of methods allowing a controller to return
results from a given vocabulary in the JSON format.  The controller does three things:

* provide a list of all terms (if allowed by the class)
* return a set of terms matching a given query
* return the complete information for a specific term given its identifier

### Sub-Authorities

Some authorties, such as Library of Congress, allow sub-authorties which is an additional parameter that
further defines the kind of authority to use with the context of a larger one.

### Examples

Return a complete list of terms:

    /terms/:vocab
    /terms/:vocab/:sub_authority

Return a set of terms matching a given query

    /search/:vocab?q=search_term
    /search/:vocab/:sub_authority?q=search_term

Return the complete information for a specific term given its identifier

    /show/:vocab/:id
    /show/:vocab/:sub_authority/:id

### JSON Results

Results are returned in JSON in this format:

    [
        {"id" : "subject_id_1", "label" : "First labels"},
        {"id" : "subject_id_2", "label" : "Printing labels"},
        {"id" : "", "label" : "This term has no id number"},
        {"id" : "", "label" : "Neither does this"}
    ]

Results for specific terms may vary according to the term.  For example:

    /show/mesh/D000001

Might return:

    { "id" : "D000001",
      "label" : "Calcimycin",
      "tree_numbers" : ["D03.438.221.173"],
      "synonyms" : ["A-23187", "A23187", "Antibiotic A23187", "A 23187", "A23187, Antibiotic"]
    }

This is due to the varing nature of each authority source.  However, results for multiple terms, such as a search, we
should always use the above id and label structure to ensure interoperability at the GUI level.

# Authority Sources information

### Library of Congress (example uses language):

Base url: http://id.loc.gov/search/

Example search (html): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2

Example search (json): http://id.loc.gov/search/?q=eng&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fvocabulary%2Fiso639-2&format=json

Example search (json, second page): http://id.loc.gov/search/?q=a*%20cs:http://id.loc.gov/vocabulary/countries&start=21&format=json

# Local Authority Files

### YAML file of terms

#### Location and Naming Convention

Local authorities are specified in YAML files, one for each sub-authority.  By default, local
authority YAML files are located in config/authorities/ .  This location can be changed by editing
the :local_path entry in config/authorities.yml.  Relative paths are assumed to be relative to
Rails.root.

Local authority YAML files are named for the sub-authority they represent.  For example, a YAML file
for the "states" sub-authority would be named states.yml.

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

# Medical Subject Headings (MeSH)

Provides autocompletion of [MeSH terms](http://www.nlm.nih.gov/mesh/introduction.html). This
implementation is simple, and only provides *descriptors* and does not implement *qualifiers* (in
the technical MeSH sense of these terms). The terms are stored in a local database, which is then
queried to provide the suggestions.

## Loading Terms

To import the mesh terms into the local database, first download the MeSH descriptor dump in ASCII
format  (see [http://www.nlm.nih.gov/mesh/filelist.html][]). Once you have this file, the rake task
`mesh:import` will load the entire file of terms into the database. It does not do an update (yet!).

    MESH_FILE=path/to/mesh.txt rake mesh:import

This may take a few minutes to finish.

# TODOs

* Make this an engine
* Provide show method to TermsController to return individual terms

check the issue list for more...

# Authors

* Stephen Anderson
* Don Brower
* Jim Coble
* Mike Durbin
* Randall Floyd
* Eric James
* Mike Stroming
* Adam Wead

