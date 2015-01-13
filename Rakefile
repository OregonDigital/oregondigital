#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'
require 'resque/scheduler/tasks'

Oregondigital::Application.load_tasks
Rake::Task[:default].prerequisites.clear
task :default => :ci
