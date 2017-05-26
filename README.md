# Questioning Authority

[![Build Status](https://travis-ci.org/samvera/questioning_authority.png?branch=master)](https://travis-ci.org/samvera/questioning_authority) [![Gem Version](https://badge.fury.io/rb/qa.png)](http://badge.fury.io/rb/qa)
[![Coverage Status](https://coveralls.io/repos/github/samvera/questioning_authority/badge.svg?branch=master)](https://coveralls.io/github/samvera/questioning_authority?branch=master)

You should question your authorities.

----
## Table of Contents

  * [What does this do?](#what-does-this-do)
  * [How does it work?](#how-does-it-work)
    * [Sub-Authorities](#sub-authorities)
  * [How do I use this?](#how-do-i-use-this)
    * [Examples](#examples)
    * [JSON Results](#json-results)
  * [Authority Sources information](#authority-sources-information)
    * [FAST](#fast)
    * [Geonames](#geonames)
    * [Adding your own authorities](#adding-your-own-authorities)
    * [Local Sub-Authorities](#local-sub-authorities)
      * [In YAML files](#in-yaml-files)
      * [In database tables](#in-database-tables)
    * [Medical Subject Headings (Mesh)](#medical-subject-headings-mesh)
    * [Linked Open Data (LOD) Authorities](#linked-open-data-lod-authorities)
      * [Configuring a LOD Authority](#configuring-a-lod-authority)
      * [Query](#query)
      * [Find term](#find-term)
      * [Add javascript to support autocomplete](#add-javascript-to-support-autocomplete)
  * [Developer Notes](#developer-notes)
    * [Compatibility](#compatibility)
  * [Help](#help)

----

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
    /qa/terms/:vocab/:subauthority

Return a set of terms matching a given query

    /qa/search/:vocab?q=search_term
    /qa/search/:vocab/:subauthority?q=search_term

Return the complete information for a specific term given its identifier

    /qa/show/:vocab/:id
    /qa/show/:vocab/:subauthority/:id

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

### FAST

In the same manner, QA provides a wrapper around OCLC's FAST autocomplete
service. The following subauthorities are available:

* all
* personal
* corporate
* event
* uniform
* topical
* geographic
* form_genre

Example qa URL: /qa/search/assign_fast/all?q=periodic+table

The result includes both 'label' and 'value' to help users select the correct
heading, e.g.:

    [
        {
            "id":"fst01789629",
            "label":"Periodic table",
            "value":"Periodic table"
        },
        {
            "id":"fst01789629",
            "label":"Periodic table (Saunders, N.) USE Periodic table",
            "value":"Periodic table"
        },...
    ]

Make sure you handle these correctly in your form.

For more details on this OCLC API, see
http://www.oclc.org/developer/develop/web-services/fast-api/assign-fast.en.html

### Geonames
Make sure you register an account and enable it to see search results.

Ensure you can run a query like this:

```
http://api.geonames.org/searchJSON?q=port&&maxRows=10&username=MY_ACCOUNT_NAME
```

Then you can set your username like this:

```ruby
Qa::Authorities::Geonames.username = 'myAccountName'

```
### Adding your own authorities

Create an authority file inside your app.

```
app/authorities/qa/authorities/your_authority.rb

```

Write module code with at least a search method.

```ruby
module Qa::Authorities
  class YourAuthority < Qa::Authorities::Base
    # Arguments can be (query) or (query, terms_controller)
    def search(_q)
      # Should return array of hashes with ids, labels, and values(optional)
      { id: '123', label: 'Title', value: 'The Title' }
    end
  end
end
```

### Local Sub-Authorities

#### In YAML files
For simple use cases when you have a few terms that don't change very often.

Run the generator to install configuration files and an example authority.

    rails generate qa:local:files

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

#### Adding your own local sub-authorities

If you'd like to add your own local authority that isn't necessarily backed by yaml, create an initializer and tell the local authority about your custom sub-authority:

```ruby
Qa::Authorities::Local.register_subauthority('names', 'LocalNames')
```

The second argument is a name of a class that represents your local authority. Then when you go to:

    /qa/search/local/names?q=Zoia

You'll be searching with an instance of `LocalNames`

### In database tables

Run the generator to install configuration files and an example authority.

    rails generate qa:local:tables
    rake db:migrate

  **Note: If you are using MYSQL as your database use the MSQL database generator instead**

    rails generate qa:local:tables:mysql
    rake db:migrate

This will create two tables/models Qa::LocalAuthority and Qa::LocalAuthorityEntry. You can then add terms to each:

    language_auth = Qa::LocalAuthority.find_or_create_by(name: 'language')
    Qa::LocalAuthorityEntry.create(local_authority: language_auth,
                                   label: 'French',
                                   uri: 'http://id.loc.gov/vocabulary/languages/fre')
    Qa::LocalAuthorityEntry.create(local_authority: language_auth,
                                   label: 'Uighur',
                                   uri: 'http://id.loc.gov/vocabulary/languages/uig')

Unfortunately, Rails doesn't have a mechnism for adding functional indexes to tables, so if you have a lot of rows, you'll want to add an index:

    CREATE INDEX "index_qa_local_authority_entries_on_lower_label" ON
      "qa_local_authority_entries" (local_authority_id, lower(label))

  **Note: If you are using MYSQL as your database and used the MSQL database gerator we tried to execute the correct SQL to create the virtual fields and indexes for you**

Finall you want register your authority in an initializer:

    Qa::Authorities::Local.register_subauthority('languages', 'Qa::Authorities::Local::TableBasedAuthority')

  **Note: If you are using MYSQL as your database and used the MSQL database gerator register the MysqlTableBasedAuthority instead of the TableBasedAuthority**

Then you can search for

    /qa/search/local/languages?q=Fre

Results are in JSON.

    [{"id":"http://id.loc.gov/vocabulary/languages/fre","label":"French"}]

The entire list (up to the first 1000 terms) can also be returned using:

    /qa/terms/local/languages/

#### Loading RDF data into database tables

 You can use the Qa::Services::RDFAuthorityParser to import rdf files into yopur database tables.  See the class file, lib/qa/services/rdf_authority_parser.rb, for examples and more information.
 To run the class in your local project you must include `gem 'linkeddata'` into your Gemfile and `require 'linkeddata'` into an initializer or your application.rb

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

### Linked Open Data (LOD) Authorities

You will need to add gems that process the type of linked data returned for the authorities you use.

To cover all possible formats, include the [ruby-rdf/linkeddata](https://github.com/ruby-rdf/linkeddata) gem.

```
gem 'linkeddata'
```

This gem is included in QA for development and testing of QA, but is not automatically included in the released gem.
Additionally, it is unlikely that you will need all the formats included by that gem.  You may want to select only those
gems that are for the formats you need supported.

See all gems in [linkeddata.gemspec](https://github.com/ruby-rdf/linkeddata/blob/develop/linkeddata.gemspec).

For example, if you know the authorites you are working with support rdf-xml, you can include the following gem instead of linkeddata.

```
gem 'rdf-rdfxml'
```

#### Configuring a LOD Authority

Access to LOD authorities can be configured.  Currently, a configuration exists in QA for OCLC Fast Linked Data, Library of
Congress (terms only), and Agrovoc.  Look for configuration files in
[/config/authorities/linked_data](https://github.com/samvera/questioning_authority/tree/master/config/authorities/linked_data).

Example configuration...

```json
{
  "term": {
    "url": {
      "@context": "http://www.w3.org/ns/hydra/context.jsonld",
      "@type":    "IriTemplate",
      "template": "http://id.worldcat.org/fast/{?term_id}/rdf.xml",
      "variableRepresentation": "BasicRepresentation",
      "mapping": [
        {
          "@type":    "IriTemplateMapping",
          "variable": "term_id",
          "property": "hydra:freetextQuery",
          "required": true
        }
      ]
    },
    "qa_replacement_patterns": {
      "term_id": "term_id"
    },
    "language": ["en","fr"]
    "term_id": "ID",
    "results": {
      "id_predicate":       "http://purl.org/dc/terms/identifier",
      "label_predicate":    "http://www.w3.org/2004/02/skos/core#prefLabel",
      "altlabel_predicate": "http://www.w3.org/2004/02/skos/core#altLabel",
      "sameas_predicate":   "http://schema.org/sameAs"
    }
  },
  "search": {
    "url": {
      "@context": "http://www.w3.org/ns/hydra/context.jsonld",
      "@type": "IriTemplate",
      "template": "http://experimental.worldcat.org/fast/search?query={?subauth}+all+%22{?query}%22&sortKeys=usage&maximumRecords={?maximumRecords}",
      "variableRepresentation": "BasicRepresentation",
      "mapping": [
        {
          "@type": "IriTemplateMapping",
          "variable": "query",
          "property": "hydra:freetextQuery",
          "required": true
        },
        {
          "@type": "IriTemplateMapping",
          "variable": "subauth",
          "property": "hydra:freetextQuery",
          "required": false,
          "default": "cql.any"
        },
        {
          "@type": "IriTemplateMapping",
          "variable": "maximumRecords",
          "property": "hydra:freetextQuery",
          "required": false,
          "default": "20"
        }
      ]
    },
    "qa_replacement_patterns": {
      "query":   "query",
      "subauth": "subauth"
    },
    "language": ["en"]
    "results": {
      "id_predicate":       "http://purl.org/dc/terms/identifier",
      "label_predicate":    "http://www.w3.org/2004/02/skos/core#prefLabel",
      "sort_predicate":     "http://www.w3.org/2004/02/skos/core#prefLabel"
    },
    "subauthorities": {
      "topic":          "oclc.topic",
      "geographic":     "oclc.geographic",
      "event_name":     "oclc.eventName",
      "personal_name":  "oclc.personalName",
      "corporate_name": "oclc.corporateName",
      "uniform_title":  "oclc.uniformTitle",
      "period":         "oclc.period",
      "form":           "oclc.form",
      "alt_lc":         "oclc.altlc"
    }
  }
}
```

NOTES:
* term: (optional) is used to define how to request term information from the authority and how to interpret results.
  * url: (required) templated link representation of the authority API URL and mapping of parameters for requesting term information from the authority
    * template: is the authority API URL with placeholders for substitution parameters in the form {?var_name}
      * NOTE: {?term_id} (required) and {?subauth} (optional) are expected to match to QA params (see qa_replacement_patterns to match QA params with mapping variables)
      * Additional substitutions can be made in the authority API if supported by the authority by adding additional mappings.  Search has an example with maximumRecords.
        * variable: should match a replacement pattern in the template  (e.g. variable: maximumRecords  ==>  {?maximumRecords}
        * required: true | false  (NOTE: Not enforced at this time.)
        * default: provide a default value that will be used if not specified
      * See (documentation of templated-links)[http://www.hydra-cg.com/spec/latest/core/#templated-links] for more information.
  * qa_replacement_patterns: identifies which mapping variables are being used for term_id and subauth.
    * NOTE: The URL to make a term request via QA always uses term_id and subauth as the param names.  qa_replacement_patters allows the url template to use a different variable name for pattern replacement.
  * language:  (optional)  values:  array of en | fr | etc.  -- identify language to use to include in results, filtering out triples of other languages
    * NOTE: Some authoritys' API URL allows language to be specified as a parameter.  In that case, use pattern replacement to add the language to the API URL to prevent alternate languages from being returned in the results.
    * NOTE: At this writing, only label and altlabel are filtered.
  * term_id:  (optional)  values:  ID (default) | URI  - This tells apps whether `__TERM_ID__` replacement is expecting an ID or URI.
  * results: (required)  lists predicates to select out for normalization in the hash results
    * id_predicate:  (optional)
    * label_predicate:  (required)
    * altlabel_predicate:  (optional)
    * sameas_predicate:  (optional)
    * narrower_predicate:  (optional)
    * broader_predicate:  (optional)
  * subauthorities:  (optional)
    * subauthority name (e.g. topic:, personal_name:, corporate_name, etc.)  Value for {?subauth} are limited to the values in the list of subauthorities.

* search: (optional) is used to define how to send a query to the authority and how to interpret results.
  * url: (required) templated link representation of the authority API URL and mapping of parameters for sending a query to the authority
    * template: is the authority API URL with placeholders for substitution parameters in the form {?var_name}
      * NOTE: {?query} (required) and {?subauth} (optional) are expected to match to QA params (see qa_replacement_patterns to match QA params with mapping variables)
      * Additional substitutions can be made in the authority API if supported by the authority by adding additional mappings.  Search has an example with maximumRecords.
        * variable: should match a replacement pattern in the template  (e.g. variable: maximumRecords  ==>  {?maximumRecords}
        * required: true | false  (NOTE: Not enforced at this time.)
        * default: provide a default value that will be used if not specified
      * See (documentation of templated-links)[http://www.hydra-cg.com/spec/latest/core/#templated-links] for more information.
  * qa_replacement_patterns: identifies which mapping variables are being used for term_id and subauth.
    * NOTE: The URL to make a term request via QA always uses term_id and subauth as the param names.  qa_replacement_patters allows the url template to use a different variable name for pattern replacement.
  * language:  (optional)  values:  array of en | fr | etc.  -- identify language to use to include in results, filtering out triples of other languages
    * NOTE: Some authoritys' API URL allows language to be specified as a parameter.  In that case, use pattern replacement to add the language to the API URL to prevent alternate languages from being returned in the results.
    * NOTE: At this writing, only label and altlabel are filtered.
  * results: (required)  lists predicates to normalize and include in json results
    * id_predicate:  (optional)
    * label_predicate:  (required)
    * altlabel_predicate:  (optional)
  * subauthorities:  (optional)
    * subauthority name (e.g. topic:, personal_name:, corporate_name, etc.)  Value for {?subauth} are limited to the values in the list of subauthorities.


##### Add new configuration
You can add linked data authorities by adding configuration files to your rails app in `Rails.root/config/authorities/linked_data/YOUR_AUTH.json`

##### Modify existing configuration
To modify one of the QA supplied configurations, copy it to your app in `Rails.root/config/authorities/linked_data/YOUR_AUTH.json`.  Make your modifications to the json configuration file in your app.

#### Query
To query OCLC Fast Linked Data service by code...

```ruby
# Search OCLC Fast all sub-authorities with default value for number of results to return
lda = Qa::Authorities::LinkedData::GenericAuthority.new(:OCLC_FAST)
ld_results = lda.search "Cornell University"

# Search OCLC Fast all sub-authorities passing in value for number of results to return
lda = Qa::Authorities::LinkedData::GenericAuthority.new(:OCLC_FAST)
ld_results = lda.search "Cornell University",{"maximumRecords" => "5"}

# Search OCLC Fast Corporate Name sub-authority passing in value for number of results to return
lda = Qa::Authorities::LinkedData::GenericAuthority.new(:OCLC_FAST,'corporate_name')
ld_results = lda.search "Cornell University",{"maximumRecords" => "3"}
```

or by URL when QA is an installed gem in an app...

```
http://localhost:3000/qa/search/linked_data/oclc_fast?q=Cornell&maximumRecords=3
```

Returns results in the format...

```json
[{"uri":"http://id.worldcat.org/fast/530369","id":"530369","label":"Cornell University"},
 {"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
 {"uri":"http://id.worldcat.org/fast/557490","id":"557490","label":"New York State School of Industrial and Labor Relations"}]
```

NOTE: For some authorities, the uri and id will both be the uri.

and with subauthority...

```
http://localhost:3000/qa/search/linked_data/oclc_fast/personal_name?q=Cornell&maximumRecords=3
```

returning results...

```json
[{"uri":"http://id.worldcat.org/fast/5140","id":"5140","label":"Cornell, Joseph"},
 {"uri":"http://id.worldcat.org/fast/72456","id":"72456","label":"Cornell, Sarah Maria, 1802-1832"},
 {"uri":"http://id.worldcat.org/fast/409667","id":"409667","label":"Cornell, Ezra, 1807-1874"}]
```

#### Find term
To find a single term in OCLC Fast Linked Data service by code...

```ruby
# Search OCLC Fast all sub-authorities with default value for number of results to return
lda = Qa::Authorities::LinkedData::GenericAuthority.new(:OCLC_FAST_ALL)
ld_results = lda.find 530369
```

or by URL when QA is an installed gem in an app...

```
http://localhost:3000/qa/show/linked_data/oclc_fast/530369
```

Returns results in the format...

```json
{"uri":"http://id.worldcat.org/fast/530369",
 "id":"530369","label":"Cornell University",
 "altlabel":["Ithaca (N.Y.). Cornell University","Kornelʹskii universitet","Kʻang-nai-erh ta hsüeh"],
 "sameas":["http://id.loc.gov/authorities/names/n79021621","https://viaf.org/viaf/126293486"],
 "predicates":{
   "http://purl.org/dc/terms/identifier":"530369",
   "http://www.w3.org/2004/02/skos/core#inScheme":["http://id.worldcat.org/fast/ontology/1.0/#fast","http://id.worldcat.org/fast/ontology/1.0/#facet-Corporate"],
   "http://www.w3.org/1999/02/22-rdf-syntax-ns#type":"http://schema.org/Organization",
   "http://www.w3.org/2004/02/skos/core#prefLabel":"Cornell University",
   "http://schema.org/name":["Cornell University","Ithaca (N.Y.). Cornell University","Kornelʹskii universitet","Kʻang-nai-erh ta hsüeh"],
   "http://www.w3.org/2004/02/skos/core#altLabel":["Ithaca (N.Y.). Cornell University","Kornelʹskii universitet","Kʻang-nai-erh ta hsüeh"],
   "http://schema.org/sameAs":["http://id.loc.gov/authorities/names/n79021621","https://viaf.org/viaf/126293486"]}}
```

NOTE: All predicates with the URI as the subject will be included under "predicates" key.  The selected keys are determined by the configuration file and can be one or more of id_predicate, label_predicate (required), altlabel_predicate, sameas_predicate, narrower_predicate, or broader_predicate.

#### Add javascript to support autocomplete

See [Using with autocomplete in Sufia](https://github.com/samvera/questioning_authority/wiki/Using-with-autocomplete-in-Sufia) in the wiki documentation for QA.



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
