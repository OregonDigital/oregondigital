OregonDigital
=============

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
