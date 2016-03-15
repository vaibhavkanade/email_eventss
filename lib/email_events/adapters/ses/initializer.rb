require 'sns_endpoint'
require 'net/http'

module EmailEvents::Adapters
  module Ses
    class Initializer < Abstract::Initializer
      def self.load_adapter?
        smtp_settings = Rails.configuration.action_mailer.smtp_settings
        smtp_settings.present? && smtp_settings[:address].include?('amazonaws.com')
      end

      def self.initialize
        SnsEndpoint.setup do |config|
          config.topics_list = SnsEndpointTopicListMatcher.new ['email_events']
          config.message_proc = EmailEvents::Service::HandleEvent
          config.subscribe_proc = Proc.new do |data|
            # confirm the subscription
            confirmation_endpoint = URI.parse(data['SubscribeURL'])
            Net::HTTP.get confirmation_endpoint
          end
        end
      end
    end

    class SnsEndpointTopicListMatcher < Array
      # match any topic ending in the topic name (as opposed to the long ARN topic ID)
      def include?(arn)
        self.any? {|topic| arn.end_with? topic}
      end
    end
  end
end
