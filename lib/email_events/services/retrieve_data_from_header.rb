class EmailEvents::Service::RetrieveDataFromHeader < EmailEvents::Service
  def initialize(message_id, sendgrid_data: nil)
    @message_id = message_id
    @sendgrid_data = sendgrid_data
  end

  def call
    # try to find the SentEmailData by the following methods, listed in order of preference:
    # 1) the Message-ID (in which we stored our own SentEmailData id in the first place);
    # 2) the sg_message_id which Sendgrid uses to track emails;
    # 3) recipient email addresses to which we recently sent out emails

    unless @message_id.blank?
      uuid = parse_header_data_to_uuid
      sent_email_data = SentEmailData.find_by_uuid!(uuid)

      # if this event gives us our Message-ID and Sendgrid's sg_message_id, we take the opportunity to store
      # the later as other events (foremost, "open" events) don't necessarily provide us with the Message-ID again
      if sent_email_data.provider_message_id.blank? && !provider_message_id.blank?
        sent_email_data.update_attribute(:provider_message_id, provider_message_id)
      end

      # the UUID is always associated with just one original message
      return [SentEmailData.find_by_uuid!(uuid)]
    end

    unless provider_message_id.blank?
      sent_email_data = SentEmailData.where(provider_message_id: provider_message_id).first
      return [sent_email_data] unless sent_email_data.nil?
    end

    # if the destination mail server has clobbered our tracking data in the message_id, still try to determine
    # the sent email data based on the sender's email address and any emails sent to it in the last 15 minutes.
    # We only do this for bounces and drops, as it's safe to assume that a bounce and drop event should apply
    # to ALL outstanding sent emails -- as opposed to eg. click and open events which are tightly associated with one
    # sent email)
    if @sendgrid_data && @sendgrid_data['event'].in?(['bounce', 'dropped'])
      return SentEmailData.where('created_at > ? AND "to" = ?', sendgrid_event_timestamp-15.minutes, sendgrid_recipient)
    end
  end

  private

  def parse_header_data_to_uuid
    return nil if @message_id.nil?

    matching_data = @message_id.match(/([^\<]+)\@uuid/)
    return nil if matching_data.nil?

    matching_data[1]
  end

  def provider_message_id
    return nil if @sendgrid_data.nil?
    @sendgrid_data['sg_message_id']
  end

  def sendgrid_event_timestamp
    return nil if @sendgrid_data.nil?
    Time.at @sendgrid_data['timestamp']
  end

  def sendgrid_recipient
    return nil if @sendgrid_data.nil?
    @sendgrid_data['email']
  end
end
