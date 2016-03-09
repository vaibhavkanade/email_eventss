$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'bundler/setup'

require 'combustion'

require 'action_mailer'

# get combustion to trigger our railties
Combustion.initialize! :all

require 'email_events'
require 'internal/mailers/test_mailer'

