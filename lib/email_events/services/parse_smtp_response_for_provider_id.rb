class EmailEvents::Service::ParseSmtpResponseForProviderId < EmailEvents::Service
  include Virtus.model
  attribute :mail_message, Mail::Message
  attribute :raw_response, Net::SMTP::Response
  attribute :sent_email_data_class

  def call
    # parse the response using the applicable SmtpResponse adapter
    provider_id = parsed_response.provider_id
    return if provider_id.nil?

    # find our SentEmailData from our own UUID and store the provider id
    sent_email_data = sent_email_data_class.find_by_uuid(message_uuid)
    sent_email_data.update_attribute(:provider_message_id, provider_id)
  end

  private
  def response_class
    "EmailEvents::Adapters::#{EmailEvents.provider}::SmtpResponse".constantize
  end

  def parsed_response
    @parsed_response = response_class.new(raw_response)
  end

  def message_uuid
    mail_message.message_id.match(/(.+)\@uuid/)[1]
  end
end
