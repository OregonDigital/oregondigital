OregonDigital
=============

[![Circle CI](https://circleci.com/gh/OregonDigital/oregondigital.svg?style=svg)](https://circleci.com/gh/OregonDigital/oregondigital)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/oregondigital/badge.png)](https://coveralls.io/r/OregonDigital/oregondigital)
<!--![BrowserStack Status](https://www.browserstack.com/automate/badge.svg?badge_key=<badge_key>)-->

Overview
-----
Current production Oregon Digital running Fedora 3 and Hydra 6.

New development is focused on Oregon Digital 2: http://github.com/OregonDigital/oregondigital_2

Connected projects:
  - [csv2bag](https://github.com/OregonDigital/csv2bag) - bulk ingest from CSV
  - [cdm2bag](https://github.com/OregonDigital/cdm2bag) - bulk ingest from CONTENTdm
  - [ControlledVocabularyManager](https://github.com/OregonDigital/ControlledVocabularyManager) - Rails app with Blazegraph powering [OpaqueNamespace.org](http://opaquenamespace.org/)

<a href="https://www.browserstack.com">
  <img src="https://rawgit.com/OregonDigital/development-practices/master/images/browserstack.svg" width="100%" height="64">
</a>


Local Development Setup
-----

### Using Docker

#### Grab everything you need

```bash
# Grab the repository
git clone git@github.com:OregonDigital/oregondigital.git

# Start the whole stack - on your first run, this can take a while to download
# all the necessary images
docker-compose up -d
```

#### Making zoomable images work

Create `config/app.yml` with information about how to reach your local system's
RAIS container; e.g.:

    iip_server:
      location: http://localhost:12415/images/dzi

You may need to choose something other than localhost if you're doing a demo or
running docker inside a virtual machine.  The rest of the settings (port and
path) should remain untouched.

#### Generate filler data

First, run the rake task:

    docker-compose exec workers bundle exec rake filler_data

Next, log into the main application by browsing to
`http://localhost:3000/users/sign_in`.  Docker sets up the admin user as
"admin@example.org" with the password "admin123".  Once you're signed in, visit
`http://localhost:3000/resque/overview` and watch the queue slowly get
processed.  This can take a while, but once it's done you should have 3
collections of dummy data.

#### Testing

Easy as `./docker/test.sh`!  Except....

- Want to focus tests?  Just pass in a path: `./docker/test.sh spec/models`.
- If you need to ensure your environment is pristine, use the `--destroy` flag,
  which will destroy and rebuild all containers.

#### Updating Gems

The safest way to update gems is to destroy and rebuild the dev image,
otherwise you're only updating gems within a container, and containers do not
necessarily persist very long.

    docker-compose stop
    docker-compose rm
    docker rmi oregondigital/od1-dev
    docker-compose build workers

You can also run "bundle install" inside a particular container, but this should
only be done if you know what you're doing.  It can get really confusing when you
accidentally use `docker-compose run` when you meant `docker-compose exec`.  Or
if you choose the wrong container name.

#### Various other docker stuff

This list of commands should get you moving forward with most typical
development tasks:

```bash
# When you change code, if you start getting odd errors, you may have to
# restart the OD containers:
docker-compose restart web workers resquehead

# If things are still "weird", rebuild the OD containers:
docker-compose stop web workers resquehead
docker-compose rm web workers resquehead
docker-compose build web workers resquehead
docker-compose up -d

# If you need a "hard reset", nuke it!  WARNING: THIS WILL REMOVE ALL YOUR
# DEVELOPMENT-INGESTED ASSETS!
./docker/nuke.sh

# When nukes just don't destroy enough, try out a SUPERNOVA!  This will remove
# every Docker entity related to OD, which will mean re-downloading the images:
./docker/supernova.sh

# Watch the logs for everything
docker-compose logs -f

# Just watch the Rails web app logs
docker-compose logs -f web
```

### Manual

**Requires Ruby 2.0**

(Mongo needs to be running, 2.4 is known to work: https://docs.mongodb.com/v2.4/tutorial/install-mongodb-on-ubuntu/ )

    git clone git@github.com:OregonDigital/oregondigital.git
	cd oregondigital
	bundle install
	rake db:migrate
	git submodule init
	git submodule update
	rake hydra:jetty:config

On a newer install, may have to pin 

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
