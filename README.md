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
docker pull oregondigital/solr
docker pull oregondigital/phantomjs:1.8.1
docker pull oregondigital/hydra-jetty:3.8.1-4.0
```

```bash
# Grab the repository
git clone git@github.com:OregonDigital/oregondigital.git

# Start the whole stack
docker-compose up -d

# When you change code, rebuild the OD containers
docker-compose stop web workers resquehead
docker-compose rm web workers resquehead
docker-compose build web workers resquehead
docker-compose up -d

# Run a rake task - in this case, to create filler data
docker-compose exec web bundle exec rake filler_data

# Watch the logs for everything
docker-compose logs -f

# Just watch the Rails web app logs
docker-compose logs -f web
```

#### Testing

Easy as `./docker/test.sh`!  Except....

In order to test, you need `phantombin/phantomjs`.  This is available in the
`oregondigital/phantomjs:1.8.1` image.  As long as you have that image, the
test script will automatically copy phantomjs into your test container at
runtime.

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
