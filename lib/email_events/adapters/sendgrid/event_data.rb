module EmailEvents::Adapters
  module Sendgrid
    class EventData < Abstract::EventData
      def event_type
        @sendgrid_event[:event]
      end

      def event_timestamp
        return nil if @sendgrid_data.nil?
        Time.at @sendgrid_data['timestamp']
      end

      def recipient
        return nil if @sendgrid_data.nil?
        @sendgrid_data['email']
      end

      def smtp_status_code
        return nil if @sendgrid_event[:status].blank?

        @sendgrid_event[:status].gsub(/\./,'').to_i
      end

      def reason
        @sendgrid_event[:reason]
      end

      def smtp_message_id
        @sendgrid_event['sg_message_id']
      end

      def provider_message_id
        @sendgrid_event['smtp-id']
      end
    end
  end
end