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

### Using Docker

Pull images from dockerhub to speed the setup - phantomjs in particular takes a
LONG time to build:

```bash
docker pull oregondigital/od1
docker pull oregondigital/od1-test
docker pull oregondigital/solr
docker pull oregondigital/phantomjs
docker pull oregondigital/hydra-jetty:3.8.1-4.0
```

```bash
# Grab the repository
git clone git@github.com:OregonDigital/oregondigital.git

# Run the dev stack with docker-compose, nicely wrapped in a shell script
./docker/compose up

# You can run compose manually, as well, just MAKE SURE YOU PICK A CONSISTENT
# PROJECT NAME!  It must be different from your test setup!  Don't go with the
# default project name!  If you do that for dev and test, you'll end up with
# container name collisions, which could ruin your dev data!  (Or use the
# default name here, but make sure you never use it for testing)
docker-compose -p OD1 up

# Set up the database
docker-compose -p OD1 exec web bundle exec rake db:migrate
docker-compose -p OD1 exec web bundle exec rake admin_user

# If you do the above while the containers are not running, use the "run"
# subcommand instead of the "exec" subcommand, but be warned that leaves trash
# containers lying around until you clean up.
docker-compose -p OD1 run web bundle exec rake db:migrate
docker-compose -p OD1 run web bundle exec rake admin_user

# When you change code, rebuild the od container
docker-compose -p OD1 rm web
docker-compose -p OD1 build web
docker-compose -p OD1 up

# Alternatively, run dev.sh to do some extra setup such as rebuilding the OD1 image and running migrations:
./docker/dev.sh
```

You can run commands against the web head via standard compose commands using
the wrapper.  e.g., `./docker/compose exec web bundle exec rake admin_user`.

#### Testing

Easy as `./docker/test.sh`!  Except....

In order to test, you need `phantombin/phantomjs`.  This can be built and
copied automatically for you:

    docker pull oregondigital/phantomjs
    docker-compose -p ODTEST -f test-compose.yaml run phantomjs

**BUT**: it's a VERY slow process.  If you can find a 1.8.1 binary that works
in Ubuntu 12.04, you'll be a lot better off.  Once the binary is in
`phantombin/phantomjs`, you should be fine moving forward.

Other information:

- Want to focus tests?  Just pass in a path: `./docker/test.sh spec/models`.
- If you need to ensure your environment is pristine, use the `--destroy` flag,
  which will destroy and rebuild all containers.

### Manual

**Requires Ruby 2.0**

    git clone git@github.com:OregonDigital/oregondigital.git
	cd oregondigital
	bundle install
	rake db:migrate
	git submodule init
	git submodule update
	rake hydra:jetty:config

Symlink media directories:

```bash
ln -s /path/to/rails/media public/media
ln -s /path/to/rails/media/thumbnails public/thumbnails
```

Install memcached if needed, or make sure it's running (needed for login sessions):

* Ubuntu: `sudo apt-get install memcached`
* Mac/Homebrew: `brew install memcached`
* Other: http://memcached.org/downloads

Start the servers:

    rake jetty:start
	rails server

### Vagrant Setup

Requires [Git](http://www.git-scm.com/),
[VirtualBox](https://www.virtualbox.org/), and
[Vagrant](http://www.vagrantup.com/).  Also requires 3 gigs of RAM to be
available for the VM which vagrant creates.

Option 1: manual submodule setup:

    git clone git@github.com:OregonDigital/oregondigital.git
    cd oregondigital
    git submodule init
    git submodule update

Option 2: automatic submodule setup:

    git clone git@github.com:OregonDigital/oregondigital.git --recursive
    cd oregondigital

Either way, you then tell vagrant to download and start the virtual machine:

    vagrant up
    vagrant ssh

After `vagrant ssh` you'll be logged into the VM.  From there, you'll want to
start the Rails server:

    cd /vagrant
    rails server

You can browse the app via `http://localhost:3000`, and check on the jetty
container (which houses solr and fedora) at `http://localhost:8983`.
