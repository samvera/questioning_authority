# Questioning Authority

[![Build Status](https://travis-ci.org/projecthydra/questioning_authority.png?branch=master)](https://travis-ci.org/projecthydra/questioning_authority) [![Gem Version](https://badge.fury.io/rb/qa.png)](http://badge.fury.io/rb/qa)

You should question your authorities.

## What does this do?

Provides a set of uniform RESTful routes to query any controlled vocabulary or set of authority terms.
Results are returned in JSON and can be used within the context of a Rails application or any other
Ruby environment. Primary examples would include providing auto-complete functionality via Javascript 
or populating a dropdown menu with a set of terms.

## How does it work?

Authorities are defined as classes, each implementing a set of methods allowing a controller to return
results from a given vocabulary in the JSON format.  The controller does three things:

* provide a list of all terms (if allowed by the class)
* return a set of terms matching a given query
* return the complete information for a specific term given its identifier

Depending on the kind of authority or its API, the controller may not do all of these things such
as return a complete list of terms.

### Sub-Authorities

Some authorities, such as Library of Congress, allow sub-authorities which is an additional parameter that
further defines the kind of authority to use with the context of a larger one.

## How do use this?

Add the gem to your Gemfile

    gem 'qa'

Add the engine to your config/routes.rb file

    mount Qa::Engine => '/qa'

Start questioning your authorities!

### Examples

Return a complete list of terms:

    /qa/terms/:vocab
    /qa/terms/:vocab/:sub_authority

Return a set of terms matching a given query

    /qa/search/:vocab?q=search_term
    /qa/search/:vocab/:sub_authority?q=search_term

Return the complete information for a specific term given its identifier

    /qa/show/:vocab/:id
    /qa/show/:vocab/:sub_authority/:id

### JSON Results

Results are returned in JSON in this format:

    [
        {"id" : "subject_id_1", "label" : "First labels"},
        {"id" : "subject_id_2", "label" : "Printing labels"},
        {"id" : "", "label" : "This term has no id number"},
        {"id" : "", "label" : "Neither does this"}
    ]

Results for specific terms may vary according to the term.  For example:

    /qa/show/mesh/D000001

Might return:

    { "id" : "D000001",
      "label" : "Calcimycin",
      "tree_numbers" : ["D03.438.221.173"],
      "synonyms" : ["A-23187", "A23187", "Antibiotic A23187", "A 23187", "A23187, Antibiotic"]
    }

This is due to the varying nature of each authority source.  However, results for multiple terms, such as a search, we
should always use the above id and label structure to ensure interoperability at the GUI level.

# Authority Sources information

### Library of Congress

LOC already provides a REST API to query their headings. QA provides a wrapper around this to augment its
functionality and refine it so that it is congruent with the other authorities in QA.  For example,
searching subject headings from LOC uses the subjects sub-authority.  Using QA, we'd construct the URL as:

    /qa/search/loc/subjects?q=History--

In turn, this URL is passed to LOC as:

    http://id.loc.gov/search/?format=json&q=History--&q=cs:http://id.loc.gov/authorities/subjects

QA then presents this data to you in JSON format:

    [
        {"id":"info:lc/authorities/subjects/sh2008121753","label":"History--Philosophy--History--20th century"},
        {"id":"info:lc/authorities/subjects/sh2008121752","label":"History--Philosophy--History--19th century"},
        etc...
    ]

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

* Provide show method to TermsController to return individual terms

check the issue list for more...

# Known Issues

Some users have reported errors resulting from the curb gem.  When performing queries, the application will crash with the error:

    Trace/BPT trap: 5

The solution is to install the curb gem from the master branch on Github.  To do this, add the following line to the Gemfile of your
application:

    gem 'curb', github: 'taf2/curb'

# Developer Notes

To develop this gem, clone the repository, then run:

    bundle install
    rake

This will install the gems, create a dummy application under spec/internal and run the tests.  After you've made changes, remove the entire spec/internal
directory so that further tests and run against a new dummy application.

# Authors

* [Stephen Anderson](https://github.com/scande3)
* [Don Brower](https://github.com/dbrower)
* [Jim Coble](https://github.com/coblej)
* [Mike Durbin](https://github.com/mikedurbin)
* [Randall Floyd](https://github.com/stormfin)
* [Eric James](https://github.com/yulgit1)
* [Mike Stroming](https://github.com/mstroming)
* [Adam Wead](https://github.com/awead)

### Special thanks to...

[Jeremy Friesen](https://github.com/jeremyf) who gave us the name for our gem.

