module EmailEvents::Adapters
  module Ses
    class Initializer < Abstract::Initializer
      def self.load_adapter?
        smtp_settings = Rails.configuration.action_mailer.smtp_settings
        smtp_settings.present? && smtp_settings[:address].include?('sendgrid.com')
      end

      def self.initialize
        SnsEndpoint.setup do |config|
          config.topics_list = ['email_events']
          config.message_proc = EmailEvents::Service::HandleEvent
        end

        Rails.application.routes.draw do
          mount SnsEndpoint::Core => "/email_events/sendgrid"
        end

        # SNS doesn't provide us with the Message-ID, so we need to track SES's own
        # "provider id" right off the bat.  It's returned in the SMTP response, so we
        # can grab it in a mail observer when sending a message
        mail_observer = Class.new do
          def self.delivered_email(message)
            logger_info "Sent Message: #{message}"
          end
        end
        ActionMailer::Base.register_observer(mail_observer)
      end
    end
  end
end
