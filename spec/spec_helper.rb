$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'bundler/setup'

require 'combustion'

require 'action_mailer'

# get combustion to trigger our railties
Combustion.initialize! :all

require 'email_events'
require 'internal/mailers/test_mailer'

#default to a mailer configuration for sendgrid
Rails.configuration.action_mailer.smtp_settings = {
  address: "smtp.sendgrid.net",
  port: '25',
  domain: "test.com",
  authentication: :plain,
  user_name: "testuser",
  password: "test123",
  return_response: true
}

