require 'gridhook'

module EmailEvents::Adapters
  module Sendgrid
    class Initializer < Abstract::Initializer
      def self.load_adapter?
        smtp_settings = Rails.configuration.action_mailer.smtp_settings
        smtp_settings.present? && smtp_settings[:address].include?('sendgrid')
      end

      def self.initialize
        Gridhook.configure do |config|
          config.event_receive_path = '/email_events/sendgrid'

          config.event_processor = EmailEvents::Service::HandleEvent
        end
      end
    end
  end
end