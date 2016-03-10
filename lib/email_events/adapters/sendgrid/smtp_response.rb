module EmailEvents::Adapters
  module Sendgrid
    class SmtpResponse < Abstract::SmtpResponse
      def provider_message_id
        # Status OK
        return nil unless @raw_smtp_response.status == '250'

        @raw_smtp_response.string.match(/queued as (.+)/)[1]
      end
    end
  end
end