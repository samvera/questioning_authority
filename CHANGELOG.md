### 4.2.5 (2019-11-12)

* refactor to single request_header parameter for search and find methods; multi-parameters are still supported, but deprecated
* refactor Discogs to provide the same format for extended context as the linked data module  

### 4.2.4 (2019-10-17)

* use real discogs uri whenever available and discogs url when not

### 4.2.3 (2019-10-10)

* bug fix for performance stat reported for fetch normalization
* adds support for `format=nt` for linked data module and discogs module

### 4.2.2 (2019-08-12)
 
* bug fix to correctly set header content-type to text/n3 for discogs authority

### 4.2.1 (2019-08-08)

* add ability to return a single term as n3 format for linked data
* allow error from RDF::Graph to be parsed with or without parentheses around
* remove CircleCI ruby/rails version defaults (maintenance)
* adjust queries for TGN to use TGN scheme and not ULAN

### 4.2.0 (2019-06-07)

* allow property_map.optional? default value to be configurable
* make it optional whether to include blank values in linked data extended context
* allow id to be identified by multiple predicates/paths
* add music performance to loc linked data config
* improve comments about LOC special processing
* add bytes and bytes/s to performance data
* raise an exception if data can’t be normalized
* determine if loc special processing is needed based on template uri instead of authority name
* removing the test configuration for using Rails 5.0.x releases
* updates the CircleCI configuration to test against Rails releases 5.2.3, 5.1.7, and 5.0.7.2
* updates the CircleCI configuration to test against Ruby releases 2.6.3, 2.5.5, and 2.4.6

### 4.1.1 (2019-05-08)

* special processing for LOC IDs
* reset uri with every call to find
* do not discard blank nodes when filtering graph (ignored during mapping)
* improve deprecation warnings

### 4.1.0 (2019-05-03)

* add option to include performance statistics in the returned result for linked data search query and term fetch
* add option to include authority details when getting list of linked data authorities
* add support for main results to be specified as ldpath or predicate (one or the other, not mixed)
* add Discogs authority
* allow language for linked data processing to be specified in the http accept_language header
* Remove support of Rails 5.0
* Add CircleCI Support

### 4.0.0 (2019-03-08)

* refactor much of the structure of the linked data module
* refactor language processing of linked data results
* add extended context to linked data search results
* fix processing of IriTemplate mapping expansion
* add versioning to linked data configurations
* deprecate linked data config version 1.0
* update LOC and OCLCFAST linked data configs to config version 2.0
* update URL for fetching a single term from Getty through the non-linked data module
* catch and log Getty response errors
* provide better error messages with json error returned instead of empty results
* replace deprecated URI.escape with ERB::Util.url_encode
* put mesh task in the qa namespace
* remove older deprecated code
* move documentation from the README to the wiki

### 3.0.0 (2018-11-19)

* remove agrovoc linked data configuration

### 2.2.0 (2018-11-16)

* extend linked data API to include the ability to 'list' authorities, 'reload' authorities, and 'fetch'
* allow fetch of a single linked data term to be returned with format json or jsonld
* performance and accuracy enhancements to Getty vocabs query

### 2.1.2 (2018-10-01)

* add qa:apidoc generator to optionally add QA Linked Data API documentation to app using swagger

### 2.1.1 (2018-09-05)

* bugfix that allows application's ApplicationController to interact appropriately with engine's controllers

### 2.1.0 (2018-09-04)

* security vulnerability for rubocop resolved by moving to using bixby for rubocop
* add ability to sort linked data results based on a numeric ranking predicate
* filter out blanknodes from the linked data result set
* update supporting documents to match samvera community support documents
* add support for Rails 5.2
* add support for CORS headers (configurable; off by default)

### 2.0.1 (2018-02-22)

* bug fix: substitution of term id was only done when the template parameter was named term_id and not when it was named term_uri [Lynette Rayle]
* add support for configuring parameter substitution with encoded values for linked data authorities [Lynette Rayle]

### 2.0.0 (2017-10-05)

* adding support for Rails 5.1 [Lynette Rayle]
* removing support for Rails < 5.0 [Lynette Rayle]

### 1.2.0 (2017-06-23)

* provide better error messages and codes [Lynette Rayle]
* update Agrovoc URL to latest supported URL [Lynette Rayle]
* add active flag to terms defaulting to true [Josh Gum]

### 1.1.0 (2017-05-01)

* add code to process linked data authorities via configuration [Lynette Rayle]
* linked data branch refactored [Lynette Rayle]
* refactor json config, classes [Lynette Rayle]
* promote out of labs [Mike Giarlo]
* add trailing slashes to geonames uris [Justin Coyne]

### 1.0.0 (2017-03-22)

* update engine cart [Mike Giarlo]
* add coveralls [Mike Giarlo]
* make local tables generator point at the namespaced table for local authorities [Mike Giarlo]
* apply local tables change to MySQL generator as well [Mike Giarlo]
* added support for crossref funders [fundref] and publishers rest api.crossref.org (Julie Allinson]

### 0.11.1 (2017-03-01)
* 2017-02-02: BUGFIX: Use flat parameters for LOC. [Josh Gum]
* 2017-02-01: Update README with info on creating own authority versus sub-authority. [Andy Smith]
* 2017-01-23: Documentation for register_subauthority [Justin Coyne]
* 2017-01-23: Ensure up to date system gems [Jeremy Friesen]
* 2017-01-16: Deprecate WebServiceBase#get_json; use #json [Tom Johnson]
* 2017-01-15: Documentation and error handling for abstract Authority::Base [Tom Johnson]
* 2017-01-04: Remove positional arguments for Rails 5 support [Justin Coyne]

### 0.11.0 (2017-01-04)
* 2016-12-30: Pin rubocop-rspec to 1.8.0 [Justin Coyne]
* 2016-12-30: Loosen nokogiri dependency [Justin Coyne]
* 2016-11-11: Add search method to see if wants the controller with the request.  [Andy Smith]
* 2016-10-27: Stop spamming IRC with Travis builds [Michael J. Giarlo]
* 2016-10-25: Add Faraday encoder for finicky FAST api; fixes multi-word queries [Anna Headley]

### 0.5.0 (2014-04-17)
* 2015-04-14: Use a valid SPARQL query in the AAT authority [Justin Coyne]
* 2015-04-14: Decouple the path from the subauthority class name. This ensures the
route for getty aat hasn't changed. [Justin Coyne]
* 2015-04-10: Subauthority is one word. It doesn't need an underscore [Justin
Coyne]
* 2015-04-10: Rename factory() to subauthority_for() [Justin Coyne]
* 2015-04-09: Add custom local authority to the Readme. (ci skip) [Justin Coyne]
* 2015-04-09: Add the ability to register new local vocabularies [Justin Coyne]
* 2015-04-09: Extract FileBasedAuthority spec [Justin Coyne]
* 2015-04-09: Move authorities specs to an authorities directory [Justin Coyne]
* 2015-04-09: Extract sub-authorities to separate classes This helps pave the way
for adding local authorities that are not backed by a yaml file. [Justin Coyne]

### 0.4.3 (2015-04-09)
* 2015-04-07: Log a helpful message when an authority or sub-authority can't be
found [Justin Coyne]
* 2015-04-07: Raise a helpful error message if the config direcotory is missing
[Justin Coyne]

### 0.4.2 (2015-04-06)
* 2015-03-13: Use fulltext indexing [Justin Coyne]
* 2015-03-13: Set the proper accepts header for a sparql response See
http://answers.semanticweb.com/questions/31906/getty-sparql-gives-a-404-if-you-pass-accept-applicationjson
[Justin Coyne]

### 0.4.1 (2015-03-13)
* 2015-03-12: Invert the regex, so that it allows the good characters [Justin Coyne]
* 2015-03-12: Don't pass Accept header to Getty sparql [Justin Coyne]

### 0.4.0 (2015-03-12)
* 2015-03-11: Added Getty AAT vocabulary [Justin Coyne]
* 2015-01-14: Remove rails 4.2.0 from allowed failures [Justin Coyne]
* 2015-01-14: remove migration check [Justin Coyne]
* 2015-01-14: Testing Rails 4.2 [Justin Coyne]
* 2014-09-30: Update README.md [cam156]
* 2014-07-17: Check for query parameter when searching; updating to Rspec v3 syntax [Adam Wead]
* 2014-07-03: Refactoring, enabling #find for individual records [Adam Wead]
* 2014-06-26: Refactor local authorities; implement #all method [Adam Wead]
* 2014-06-26: Removing deprecated ::get_full_record [Adam Wead]
* 2014-06-26: Updating route syntax; adding tests [Adam Wead]
* 2014-06-27: Added LCMPT and AFSET sub-vocabularies to LOC [Steven Anderson]
* 2014-06-25: Updating README with MeSH instructions [Adam Wead]
* 2014-06-25: Updating EngineCart configuration [Adam Wead]

