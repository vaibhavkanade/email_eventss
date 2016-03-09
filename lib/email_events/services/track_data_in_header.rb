require 'virtus'

class EmailEvents::Service::TrackDataInHeader < EmailEvents::Service
  include Virtus.model

  attribute :mailer, ActionMailer::Base
  attribute :sent_email_data_class
  attribute :data

  def call
    # a UUID is much more secure identifier to send along in an email header (as opposed to the db primary key,
    # for which someone could easily guess a valid integer in an attack)
    uuid = generate_uuid

    sent_email_data_class.create!(
      mailer_class: mailer_class,
      mailer_action: mailer_action,
      to: recipient_email,
      uuid: uuid,
      data: data
    )

    # add the uuid to of the SentEmailData to the email Message-ID header for tracking it
    add_data_uuid_to_email_headers(uuid)
  end

  private
  def mailer_class
    mailer.to_s
  end

  def mailer_action
    mailer.action_name
  end

  def recipient_email
    mailer.headers.to.first
  end

  def generate_uuid
    UUIDTools::UUID.random_create.to_s.gsub(/\-/,'')
  end

  def add_data_uuid_to_email_headers(content)
    mailer.headers["Message-ID"] = "<#{content}@uuid.email_events>"
  end
end
