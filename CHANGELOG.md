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

