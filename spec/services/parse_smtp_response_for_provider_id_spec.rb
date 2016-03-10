require 'spec_helper'

describe EmailEvents::Service::ParseSmtpResponseForProviderId do
  let(:uuid) { "testuuid" }
  let(:provider_id) { "yrQZv_deQL-48_-wVWOjuA" }

  let(:mail_message) { TestMailer.hello }
  let(:smtp_response) {
    OpenStruct.new(status: '250', string: "250 Ok: queued as #{provider_id}\n")
  }
  let(:sent_email_data) {
    EmailEvents::SentEmailData.create(mailer_class: 'TestMailer', mailer_action: 'hello', to: 'test@test.com', uuid: uuid)
  }

  before do
    mail_message.message_id = "#{uuid}@uuid.email_events"
  end

  it "saves the provider id to the sent email data" do
    # create the sent email data
    sent_email_data

    EmailEvents::Service::ParseSmtpResponseForProviderId.call(
      mail_message: mail_message,
      raw_response: smtp_response,
      sent_email_data_class: EmailEvents::SentEmailData
    )

    expect(sent_email_data.reload.provider_message_id).to eq provider_id
  end
end
