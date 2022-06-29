# Questioning Authority

Code: [![Gem Version](https://badge.fury.io/rb/qa.png)](http://badge.fury.io/rb/qa) [![Build Status](https://circleci.com/gh/samvera/questioning_authority.svg?style=svg)](https://circleci.com/gh/samvera/questioning_authority) [![Coverage Status](https://coveralls.io/repos/github/samvera/questioning_authority/badge.svg?branch=main)](https://coveralls.io/github/samvera/questioning_authority?branch=main)

Docs: [![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md) [![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Jump In: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

You should question your authorities.

--------------------------------------------------------------------------------

## Table of Contents

- [What does this do?](#what-does-this-do)
- [How does it work?](#how-does-it-work)

  - [Sub-Authorities](#sub-authorities)

- [How do I use this?](#how-do-i-use-this)

  - [Basic QA Requests](#basic-qa-requests)
  - [Typical JSON Results](#typical-json-results)

- [Authority Sources information](#authority-sources-information)

- [Developer Notes](#developer-notes)

  - [Compatibility](#compatibility)
  - [Product Owner & Maintenance](#product-owner--maintenance)

    - [Product Owner](#product-owner)

- [Help](#help)

- [Acknowledgments](#acknowledgments)

## Not seeing documentation you used to find in the README?

Much of the documentation has moved to the [Questioning Authority wiki](https://github.com/samvera/questioning_authority/wiki) to allow for better organization. We hope that you will find this easier to use.

--------------------------------------------------------------------------------

## What does this do?

Provides a set of uniform RESTful routes to query any controlled vocabulary or set of authority terms. Results are returned in JSON and can be used within the context of a Rails application or any other Ruby environment. Primary examples would include providing auto-complete functionality via Javascript or populating a dropdown menu with a set of terms.

## How does it work?

Authorities are defined as classes, each implementing a set of methods allowing a controller to return results from a given vocabulary in the JSON format. The controller does three things:

- provide a list of all terms (if allowed by the class)
- return a set of terms matching a given query
- return the complete information for a specific term given its identifier

Depending on the kind of authority or its API, the controller may not do all of these things such as return a complete list of terms.

### Sub-Authorities

Some authorities, such as Library of Congress, allow sub-authorities which is an additional parameter that further defines the kind of authority to use with the context of a larger one.

## How do I use this?

Add the gem to your Gemfile

```
gem 'qa'
```

Run bundler

```
bundle install
```

Install the gem to your application

```
rails generate qa:install
```

This will copy over some additional config files and add the engine's routes to your `config/route.rb`.

Start questioning your authorities!

### Basic QA Requests

These show the basic routing patterns for connecting to authorities. See the [Questioning Authority wiki](https://github.com/samvera/questioning_authority/wiki) documentation for detailed documentation and examples for each authority and local authorities.

Return a complete list of terms:

```
/qa/terms/:vocab
/qa/terms/:vocab/:subauthority
```

Return a set of terms matching a given query

```
/qa/search/:vocab?q=search_term
/qa/search/:vocab/:subauthority?q=search_term
```

Return the complete information for a specific term given its identifier

```
/qa/show/:vocab/:id
/qa/show/:vocab/:subauthority/:id
```

### Typical JSON Results

Results are returned in JSON in this format:

```
[
    {"id" : "subject_id_1", "label" : "First labels"},
    {"id" : "subject_id_2", "label" : "Printing labels"},
    {"id" : "", "label" : "This term has no id number"},
    {"id" : "", "label" : "Neither does this"}
]
```

# Authority Sources information

See the [Questioning Authority wiki](https://github.com/samvera/questioning_authority/wiki) for documentation on how to connect to the supported authorities, documentation on how to create new authorities, and other useful tips.

# Developer Notes

[How to Contribute](./CONTRIBUTING.md)

To develop this gem, clone the repository, then run:

```
bundle install
rake ci
```

This will install the gems, create a dummy application under spec/internal and run the tests. After you've made changes, make sure you've included tests and run the test suite with a new sample application:

```
rake engine_cart:clean
rake ci
```

Commit your features into a new branch and submit a pull request.

## Contributing 

If you're working on PR for this project, create a feature branch off of `main`. 

This repository follows the [Samvera Community Code of Conduct](https://samvera.atlassian.net/wiki/spaces/samvera/pages/405212316/Code+of+Conduct) and [language recommendations](https://github.com/samvera/maintenance/blob/main/templates/CONTRIBUTING.md#language).  Please ***do not*** create a branch called `master` for this repository or as part of your pull request; the branch will either need to be removed or renamed before it can be considered for inclusion in the code base and history of this repository.

## Compatibility
This code works with the latest versions of:
 - Rails 6.1, 6.0, 5.2 and 5.1.
 - Ruby 3.0, 2.6, and 2.5.
 - You can also use Ruby 3.1, but the combination of Ruby 3.1 and Rails 6.1 comes with a caveat: your app will not be able to use `psych 4` (which ordinarily comes with 3.1). See https://bugs.ruby-lang.org/issues/17866 and https://stackoverflow.com/questions/71191685/visit-psych-nodes-alias-unknown-alias-default-psychbadalias/71192990#71192990 for an explanation. One workaround is to modify your app's `Gemfile` to hold back `psych`: `gem 'psych', '< 4'`.
See also  `.circleci/config.yml`.

## Product Owner & Maintenance

Questioning Authority is a Core Component of the Samvera community. The documentation for what this means can be found [here](http://samvera.github.io/core_components.html#requirements-for-a-core-component).

### Product Owner

[elrayle](https://github.com/elrayle)

## Releasing

1. `bundle install`
2. Increase the version number in `lib/qa/version.rb`
3. Increase the same version number in `.github_changelog_generator`
4. Update `CHANGELOG.md` by running this command:

  ```
  github_changelog_generator --user samvera --project questioning_authority --token YOUR_GITHUB_TOKEN_HERE
  ```

5. Commit these changes to the main branch

6. Run `rake release`

# Help

The Samvera community is here to help. Please see our [support guide](./SUPPORT.md).

# Acknowledgments

This software has been developed by and is brought to you by the Samvera community. Learn more at the [Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)

## Special thanks to...

[Jeremy Friesen](https://github.com/jeremyf) who gave us the name for our gem.
