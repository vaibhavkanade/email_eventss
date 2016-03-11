require "email_events/version"
require "email_events/mailer"
require "email_events/railtie"

require "email_events/models/sent_email_data"
require "email_events/adapters/abstract/initializer"
require "email_events/adapters/sendgrid/initializer"
require "email_events/adapters/ses/initializer"
require "email_events/adapters/abstract/event_data"
require "email_events/adapters/sendgrid/event_data"
require "email_events/adapters/ses/event_data"
require "email_events/adapters/abstract/smtp_response"
require "email_events/adapters/sendgrid/smtp_response"
require "email_events/adapters/ses/smtp_response"

require "email_events/services/service"
require "email_events/services/track_data_in_header"
require "email_events/services/retrieve_data_from_header"
require "email_events/services/handle_event"
require "email_events/services/parse_smtp_response_for_provider_id"

module EmailEvents
  def self.initialize
    adapter.const_get('Initializer').initialize unless adapter.nil?
  end

  def self.adapter
    # auto-detect the adapter unless it's already been explicitly set
    @adapter ||= begin
      adapter_initializer = EmailEvents::Adapters::Abstract::Initializer.descendants.find {|adapter| adapter.load_adapter?}
      return nil if adapter_initializer.nil?

      adapter_initializer.parent
    end
  end

  def self.adapter=(adapter_module)
    if adapter_module.is_a?(String) || adapter_module.is_a?(Symbol)
      @adapter = "EmailEvents::Adapters::#{adapter_module.to_s.camelize}".constantize
    else
      @adapter = adapter_module
    end
  end
end



