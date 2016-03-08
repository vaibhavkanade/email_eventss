module EmailEvents::Adapters
  module Sendgrid
    class Initializer < Abstract::Initializer
      def initialize
        Gridhook.configure do |config|
          config.event_receive_path = '/email_events/sendgrid'

          config.event_processor = EmailEvents::Service::HandleEvent
        end
      end
    end
  end
end