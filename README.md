OregonDigital
=============

[![Circle CI](https://circleci.com/gh/OregonDigital/oregondigital.svg?style=svg)](https://circleci.com/gh/OregonDigital/oregondigital)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/oregondigital/badge.png)](https://coveralls.io/r/OregonDigital/oregondigital)

Overview
-----
Current production Oregon Digital running Fedora 3 and Hydra 6.

New development is focused on Oregon Digital 2: http://github.com/OregonDigital/oregondigital_2

Connected projects:
  - [csv2bag](https://github.com/OregonDigital/csv2bag) - bulk ingest from CSV
  - [cdm2bag](https://github.com/OregonDigital/cdm2bag) - bulk ingest from CONTENTdm
  - [ControlledVocabularyManager](https://github.com/OregonDigital/ControlledVocabularyManager) - Rails app with Blazegraph powering [OpaqueNamespace.org](http://opaquenamespace.org/)


Local Development Setup
-----

```bash
# Grab the repository
git clone git@github.com:OregonDigital/oregondigital.git

# Run the dev stack with docker-compose, nicely wrapped in a shell script
./docker/compose up
```

You can run commands against the web head via standard compose commands using
the wrapper.  e.g., `./docker/compose exec web bundle exec rake admin_user`.
