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

require "email_events/models/sent_email_data"

require "email_events/services/service"
require "email_events/services/track_data_in_header"
require "email_events/services/retrieve_data_from_header"
require "email_events/services/handle_event"

module EmailEvents
  mattr_accessor :provider

  def self.initialize
    autodetect_provider if provider.nil?
    return if provider.nil?

    "EmailEvents::Adapters::#{self.provider.to_s.camelize}::Initializer".constantize.initialize
  end

  def self.autodetect_provider
    smtp_settings = Rails.configuration.action_mailer.smtp_settings
    if smtp_settings.present? && smtp_settings[:address].include?('sendgrid')
      self.provider = :sendgrid
    end

    if provider.nil?
      Rails.logger.error "Unable to detect email provider. Please set a provider with EmailEvent.provider = -- :sendgrid or :ses --"
    end
  end
end



