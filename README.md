OregonDigital
=============

[![Build Status](https://secure.travis-ci.org/OregonDigital/oregondigital.png)](http://travis-ci.org/OregonDigital/oregondigital)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/oregondigital/badge.png)](https://coveralls.io/r/OregonDigital/oregondigital)

Development Setup
------------------

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
