module EmailEvents::Adapters
  module Abstract
    class SmtpResponse
      def initialize(raw_smtp_response)
        @raw_smtp_response = raw_smtp_response
      end

      def provider_message_id
        raise "Not implemented"
      end
    end
  end
end
