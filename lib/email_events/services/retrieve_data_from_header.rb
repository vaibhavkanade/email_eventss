require 'virtus'

class EmailEvents::Service::RetrieveDataFromHeader < EmailEvents::Service
  include Virtus.model
  attribute :event_data, EmailEvents::Adapters::Abstract::EventData

  def call
    # try to find the SentEmailData by the following methods, listed in order of preference:
    # 1) the Message-ID (in which we stored our own SentEmailData id in the first place);
    # 2) the provider_message_id which Sendgrid or SES uses to track emails;
    # 3) recipient email addresses to which we recently sent out emails

    unless uuid_from_smtp_message_id.blank?
      sent_email = EmailEvents::SentEmailData.find_by_uuid!(uuid_from_smtp_message_id)

      # if this event gives us our Message-ID and Sendgrid's sg_message_id, we take the opportunity to store
      # the latter, as other events (foremost, "open" events) don't necessarily provide us with the Message-ID again
      if sent_email.provider_message_id.blank? && !self.event_data.provider_message_id.blank?
        sent_email.update_attribute(:provider_message_id, self.event_data.provider_message_id)
      end

      # the UUID is always associated with just one original message
      return [sent_email]
    end

    unless self.event_data.provider_message_id.blank?
      sent_email = EmailEvents::SentEmailData.where(provider_message_id: self.event_data.provider_message_id).first
      return [sent_email] unless sent_email.nil?
    end

    # if the destination mail server has clobbered our tracking data in the message_id, still try to determine
    # the sent email data based on the sender's email address and any emails sent to it in the last 15 minutes.
    # We only do this for bounces and drops, as it's safe to assume that a bounce and drop event should apply
    # to ALL outstanding sent emails -- as opposed to eg. click and open events which are tightly associated with one
    # sent email)
    if self.event_data.event_type.in?([:bounce, :dropped])
      return EmailEvents::SentEmailData.where('created_at > ? AND "to" = ?', self.event_data.event_timestamp-15.minutes, self.event_data.recipients.first)
    end

    []
  end

  private
  def uuid_from_smtp_message_id
    @uuid ||= begin
      unless self.event_data.smtp_message_id.blank?
        matching_data = self.event_data.smtp_message_id.match(/([^\<]+)\@uuid/)
        matching_data.nil? ? nil : matching_data[1]
      end
    end
  end
end
