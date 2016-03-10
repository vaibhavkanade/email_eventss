module EmailEvents::Adapters
  module Ses
    class EventData < Abstract::EventData
      def initialize(sns_data)
        @sns_data = sns_data

        raise "Unrecognized SES event type" if event_type.nil?
      end

      def event_type
        case @sns_data['notificationType']
        when 'Bounce'
          :bounce
        when 'Complaint'
          :spamreport
        when 'Delivery'
          :delivered
        else
          nil
        end
      end

      def event_timestamp
        Time.parse @sns_data['mail']['timestamp']
      end

      def recipients
        @sns_data['mail']['destination']
      end

      def smtp_status_code
        # only supported for bounce events
        return nil unless event_type == :bounce

        status_code_str = @ses['bounce']['bounceRecipients'].last['status']
        return nil if status_code_str.nil?

        status_code_str.gsub(/\./,'').to_i
      end

      def reason
        # only supported for bounce events
        return nil unless event_type == :bounce

        @sendgrid_data['bounce']['bounceSubType']
      end

      def smtp_message_id
        # not supported by SNS
        nil
      end

      def provider_message_id
        @ses_data['mail']['messageId']
      end

      def raw_data
        @sns_data
      end
    end
  end
end