module EmailEvents::Adapters
  module Sendgrid
    class EventData < Abstract::EventData
      def event_type
        @sendgrid_event[:event]
      end

      def status_string
        # try to get a specific status based on the smtp status code; however, if the event doesn't have an smtp
        # status code (eg. bounce events always do, but drop events only do sometimes), supply a generic one
        if !smtp_status_code.blank?
          Service::Email::ParseSmtpStatusCode.call(code: smtp_status_code)
        else
          "Unable to send email to the address provided"
        end
      end

      def smtp_status_code
        return nil if @sendgrid_event[:status].blank?

        @sendgrid_event[:status].gsub(/\./,'').to_i
      end

      def reason
        @sendgrid_event[:reason]
      end

      def provider_message_id
        @sendgrid_event['smtp-id']
      end
    end
  end
end