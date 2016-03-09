require 'spec_helper'

describe EmailEvents::Service::TrackDataInHeader do
  let(:mailer) do
    mailer = TestMailer.send(:new)
    mailer.action_name = 'hello'
    mailer.headers.to = ["dawn@test.com"]
    mailer
  end
  let(:email_data_class) { EmailEvents::SentEmailData }
  let(:custom_data) { { 'test_data' => 1 } }

  subject { EmailEvents::Service::TrackDataInHeader.call(mailer: mailer, sent_email_data_class: email_data_class, data: custom_data) }

  it "tracks the email data in the database" do
    expect { subject }.to change {EmailEvents::SentEmailData.count}.by(1)
    expect(subject.persisted?).to be true
  end

  it "generates a uuid" do
    expect(subject.uuid).not_to be_nil
  end

  it "stores the custom data" do
    expect(subject.reload.data['test_data']).to eq 1
  end

  it "tracks the UUID in the email's Message-ID header" do
    result = subject
    expect(mailer.headers['Message-ID'].to_s).to include result.uuid
  end
end
