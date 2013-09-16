OregonDigital
=============

[![Build Status](https://secure.travis-ci.org/osulp/oregondigital.png)](http://travis-ci.org/osulp/oregondigital)
[![Coverage Status](https://coveralls.io/repos/osulp/oregondigital/badge.png?branch=feature%2FCoverAlls)](https://coveralls.io/r/osulp/oregondigital?branch=feature%2FCoverAlls)

Development Setup
------------------

    git clone https://github.com/osulp/oregondigital
	cd oregondigital
	bundle install
	rake db:migrate
	git submodule init
	git submodule update
	rake hydra:jetty:config


Start the servers:

    rake jetty:start
	rails server
