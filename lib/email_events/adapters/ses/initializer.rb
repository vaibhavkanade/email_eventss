require 'sns_endpoint'

module EmailEvents::Adapters
  module Ses
    class Initializer < Abstract::Initializer
      def self.load_adapter?
        smtp_settings = Rails.configuration.action_mailer.smtp_settings
        smtp_settings.present? && smtp_settings[:address].include?('amazonaws.com')
      end

      def self.initialize
        SnsEndpoint.setup do |config|
          config.topics_list = ['email_events']
          config.message_proc = EmailEvents::Service::HandleEvent
        end

        Rails.application.routes.draw do
          mount SnsEndpoint::Core => "/email_events/ses"
        end
      end
    end
  end
end
