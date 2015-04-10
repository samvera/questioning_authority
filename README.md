# Questioning Authority

[![Build Status](https://travis-ci.org/projecthydra-labs/questioning_authority.png?branch=master)](https://travis-ci.org/projecthydra-labs/questioning_authority) [![Gem Version](https://badge.fury.io/rb/qa.png)](http://badge.fury.io/rb/qa)

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

## How do I use this?

Add the gem to your Gemfile

    gem 'qa'

Run bundler

    bundle install

Install the gem to your application

    rails generate qa:install

This will copy over some additional config files and add the engine's routes to your `config/route.rb`.

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

### Local Authorities

For simple use cases when you have a few terms that don't change very often.

Run the generator to install configuration files and an example authority.

    rails generate qa:local

This will install a sample states authority file that lists all the states in the U.S.  To query it,

    /qa/search/local/states?q=Nor

Results are in JSON.

    [{"id":"NC","label":"North Carolina"},{"id":"ND","label":"North Dakota"}]

The entire list can also be returned using:

    /qa/terms/local/states/

Local authorities are stored as YAML files, one for each sub-authority.  By default, local
authority YAML files are located in `config/authorities/`.  This location can be changed by editing
the `:local_path` entry in `config/authorities.yml`.  Relative paths are assumed to be relative to
`Rails.root`.

Local authority YAML files are named for the sub-authority they represent. The included example "states" sub-authority
is named states.yml.

To create your own local authority, create a .yml file, place it in the configured directory and query it
using the file's name as the sub-authority.  For example, if I create `foo.yml`, I would then search it using:

    /qa/search/local/foo?q=search_term

#### Supported formats

##### List of terms

	terms:
		- Term 1
		- Term 2

##### List of id and term keys and, optionally, active key

	terms:
		- id: id1
		  term: Term 1
		  active: true
		- id: id2
		  term: Term 2
		  active: false


#### Adding your own local authorities

If you'd like to add your own local authority that isn't necessarily backed by yaml, create an initializer and tell the local authority about your custom sub-authority:

```ruby
Qa::Authorities::Local.register_subauthority('names', 'LocalNames')
```

The second argument is a name of a class that represents your local authority. Then when you go to:

    /qa/search/local/names?q=Zoia

You'll be searching with an instance of `LocalNames`


### Medical Subject Headings (MeSH)

Provides autocompletion of [MeSH terms](http://www.nlm.nih.gov/mesh/introduction.html). This
implementation is simple, and only provides *descriptors* and does not implement *qualifiers* (in
the technical MeSH sense of these terms). The terms are stored in a local database, which is then
queried to provide the suggestions.

To use, run the included rake task to copy over the relevant database migrations into your application:

    rake qa:install:migrations

Then, create the tables in your database

    rake db:migrate

Now that you've setup your application to use MeSH terms, you'll now need to load the tems into your
database so you can query them locally.

To import the mesh terms into the local database, first download the MeSH descriptor dump in ASCII
format. You can read about doing this [here](http://www.nlm.nih.gov/mesh/filelist.html). Once you have this file, use the
following rake task to load the terms into your database:

    MESH_FILE=path/to/mesh.txt rake mesh:import

This may take a few minutes to finish.

**Note:** Updating the tables with new terms is currently not supported.

# Developer Notes

[How to Contribute](./CONTRIBUTING.md)

To develop this gem, clone the repository, then run:

    bundle install
    rake ci

This will install the gems, create a dummy application under spec/internal and run the tests.  After you've made changes, 
make sure you've included tests and run the test suite with a new sample application:

    rake engine_cart:clean
    rake ci

Commit your features into a new branch and submit a pull request.

## Compatibility

Currently, it is compatible with Rails 4.0 and 4.1 under both Ruby 2.0 and 2.1.

# Help 

For help with Questioning Authority, contact <hydra-tech@googlegroups.com>.

### Special thanks to...

[Jeremy Friesen](https://github.com/jeremyf) who gave us the name for our gem.
