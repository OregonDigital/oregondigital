OregonDigital
=============

[![Build Status](https://secure.travis-ci.org/OregonDigital/oregondigital.png)](http://travis-ci.org/OregonDigital/oregondigital)
[![Coverage Status](https://coveralls.io/repos/OregonDigital/oregondigital/badge.png?branch=feature%2FCoverAlls)](https://coveralls.io/r/OregonDigital/oregondigital?branch=feature%2FCoverAlls)

Development Setup
------------------

    git clone https://github.com/OregonDigital/oregondigital
	cd oregondigital
	bundle install
	rake db:migrate
	git submodule init
	git submodule update
	rake hydra:jetty:config


Start the servers:

    rake jetty:start
	rails server
