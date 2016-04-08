class EmailEvents::Service::HandleEvent < EmailEvents::Service
  def initialize(raw_response)
    @raw_response = raw_response
  end

  def call
    sent_emails = EmailEvents::Service::RetrieveDataFromHeader.call(event_data: event_data)
    return if sent_emails.blank?

    # in occasional cases (when there's no UUID), there will be multiple sent_emails that match the event: we
    # apply the event handling to each one
    sent_emails.each do |email_data|
      begin
        mailer = email_data.mailer_class.constantize.send :new
        mailer.send :__handle_event, event_data, email_data
      end
    end

    # no data to output back to Rack
    nil
  end

  private
  def event_data
    @event_data ||= event_data_adapter_class.new(@raw_response)
  end

  def event_data_adapter_class
    EmailEvents.adapter.const_get('EventData')
  end
end
