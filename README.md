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

# Alternatively, run dev.sh to do some extra setup such as rebuilding the OD1 image and running migrations:
./docker/dev.sh
```

You can run commands against the web head via standard compose commands using
the wrapper.  e.g., `./docker/compose exec web bundle exec rake admin_user`.

Testing
---

Easy as `./docker/test.sh`!  Except....

In order to test, you need `phantombin/phantomjs`.  This will be built
automatically when running the test script, but it's a VERY slow process.  If
you can find a 1.8.1 binary that works in Ubuntu 12.04, you'll be a lot better
off.  If not, the script should build it for you, but it can take a while.

Want to focus tests?  Just pass in a path: `./docker/test.sh spec/models`.

If you need to ensure your environment is pristine, use the `--destroy` flag,
which will destroy and rebuild all containers.
