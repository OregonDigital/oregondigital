OregonDigital
=============

[![Build Status](https://secure.travis-ci.org/OregonDigital/oregondigital.png)](http://travis-ci.org/OregonDigital/oregondigital)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/oregondigital/badge.png)](https://coveralls.io/r/OregonDigital/oregondigital)

Local Development Setup
-----

**Requires Ruby 2.0**

    git clone https://github.com/OregonDigital/oregondigital
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

Start the servers:

    rake jetty:start
	rails server

Vagrant Setup
-----

Requires [Git](http://www.git-scm.com/),
[VirtualBox](https://www.virtualbox.org/), and
[Vagrant](http://www.vagrantup.com/).  Also requires 3 gigs of RAM to be
available for the VM which vagrant creates.

    git clone https://github.com/OregonDigital/oregondigital
    cd oregondigital
    git submodule init
    git submodule update
    vagrant up
    vagrant ssh

After `vagrant ssh` you'll be logged into the VM.  From there, you'll want to
start the Rails server:

    cd /vagrant
    rails server

You can browse the app via `http://localhost:3000`, and check on the jetty
container (which houses solr and fedora) at `http://localhost:8983`.
