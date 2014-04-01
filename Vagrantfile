# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "Ubuntu13Chef"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/4387941/vagrant-boxes/ubuntu-13.04-mini-i386.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 8983, host: 8983

  config.vm.provision "shell",
                      inline: "source /home/vagrant/.bashrc && sudo apt-get update -qq && sudo apt-get install -qq libmagickwand-dev libvips-dev libmagic-dev graphicsmagick poppler-utils poppler-data ghostscript pdftk libreoffice redis-server git gcc build-essential libmysqlclient-dev phantomjs mongodb && cd /vagrant && rvm fix-permissions && bundle install && rake db:create && rake db:migrate && rake sets:content:sync && rake hydra:jetty:config && rake jetty:restart"
end
