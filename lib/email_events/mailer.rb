module EmailEvents
  module Mailer
    def self.included(base)
      base.class_eval do
        # whether or not to track the email and handle events for the email
        class_attribute :event_handler
        # additional metadata to store along the email, which we can pull up again when an event occurs (JSON format)
        class_attribute :tracked_data_method

        # an alternative class (generally, a subclass) instead of SentEmailData - eg. to perform validations on the
        # custom tracked_metadata
        class_attribute :sent_email_data_class

        after_action :__track_data_in_header

        protected
        def self.on_event(event_handler)
          self.event_handler = event_handler
        end

        def self.track_data_for_events(tracked_data_method)
          self.tracked_data_method = tracked_data_method
        end

        def __track_data_in_header
          return if event_handler.nil? && tracked_data_method.nil?

          Service::Email::TrackDataInHeader.call(
            mailer: self,
            sent_email_data_class: sent_email_data_class || EmailEvents::SentEmailData,
            data: __tracked_data
          )
        end

        def __tracked_data
          return nil if tracked_data_method.nil?

          if tracked_data_method.is_a? Symbol
            self.send tracked_data_method
          else
            tracked_data_method.call
          end
        end

        def __handle_event(event_data, email_data)
          return if event_handler.nil?

          if event_handler.is_a? Symbol
            self.send event_handler, event_data, email_data
          else
            event_handler.call event_data, email_data
          end
        end
      end
    end
  end
end