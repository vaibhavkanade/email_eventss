class EmailEvents::Service::HandleSendgridEvent < EmailEvents::Service
  def initialize(raw_response)
    @raw_response = raw_response
  end

  def call
    sent_emails = Service::Email::RetrieveDataFromHeader.call(message_id, event_data: event_data)
    return if sent_emails.blank?

    # in occasional cases (when there's no UUID), there will be multiple sent_emails that match the event: we
    # apply the event handling to each one
    sent_emails.each do |email_data|
      begin
        mailer = email_data.mailer_class.constantize.new
        mailer.on_email_event(event_data, email_data)
      end
    end
  end

  private
  def event_data
    @event_data ||= event_data_adapter_class.new(@raw_response)
  end

  def event_data_adapter_class
    "Adapters::#{EmailEvents.adapter}EventData".constantize
  end
end
