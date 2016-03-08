require "email_events/version"
require "email_events/mailer"
require "email_events/railtie"

require "email_events/models/sent_email_data"
require "email_events/adapters/abstract/initializer"
require "email_events/adapters/sendgrid/initializer"
require "email_events/adapters/ses/initializer"
require "email_events/adapters/abstract/event_data"
require "email_events/adapters/sendgrid/initializer"
require "email_events/adapters/ses/initializer"

require "email_events/services/service"
require "email_events/services/track_data_in_header"
require "email_events/services/retrieve_data_from_header"
require "email_events/services/parse_smtp_status_code"
require "email_events/services/handle_sendgrid_event"

module EmailEvents
  def self.adapter
    if Rails.configuration.action_mailer.smtp_settings[:address].include?('sendgrid')
      :sendgrid
    else
      raise "Unknown email provider"
    end
  end

  def self.initialize
    "EmailEvents::Adapters::#{self.adapter}::Initializer".constantize.initialize
  end
end

