module EmailEvents::Adapters
  module Sendgrid
    class EventData < Abstract::EventData
      def initialize(sendgrid_data)
        @sendgrid_data = sendgrid_data
      end

      def event_type
        @sendgrid_data['event']
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
        return nil if @sendgrid_data[:status].blank?

        @sendgrid_data[:status].gsub(/\./,'').to_i
      end

      def reason
        @sendgrid_data[:reason]
      end

      def smtp_message_id
        @sendgrid_data['smtp-id']
      end

      def provider_message_id
        @sendgrid_data['sg_message_id']
      end
    end
  end
end