Combustion::Application.configure do
  # non-functional test Sengrid config (setup for testing the email provider auto-detect)
  config.action_mailer.smtp_settings = {
    :address => "smtp.sendgrid.net",
    :port => '25',
    :domain => "test.com",
    :authentication => :plain,
    :user_name => "test@test.com",
    :password => "test123"
  }
end
