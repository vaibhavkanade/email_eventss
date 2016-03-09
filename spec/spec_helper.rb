$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'bundler/setup'

require 'combustion'

# get combustion to trigger our railties
Combustion.initialize! :all

require 'email_events'

