require 'spec_helper'

describe EmailEvents::Service::RetrieveDataFromHeader do
  let(:uuid) { "66d0d6d13a14407b2da9571e481fed1" }
  let(:message_id) { "<#{uuid}@uuid.email_events>" }
  let(:sendgrid_data) do
    bounce_fixture = JSON.parse(IO.read(Rails.root.join('spec','fixtures','sendgrid_events.json')))['bounce']
    bounce_fixture.merge({
      'smtp-id' => message_id,
      'timestamp' => Time.now.to_i,
      'email' => 'user@test.com'
    }).with_indifferent_access
  end

  let(:sent_email_data) { EmailEvents::SentEmailData.create(uuid: uuid, mailer_action: 'mail', to: 'user@test.com') }

  context "event contains message-id tracking data" do
    before do
      # make sure we're finding it by the uuid and not the email address
      sent_email_data.update_attribute(:to, 'null@null.com')
    end

    it "finds the sent_email_data from the message-id" do
      expect(Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)).to eql [sent_email_data]
    end

    it "stores Sendgrid's sg_message_id" do
      Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)
      expect(sent_email_data.reload.provider_message_id).to eq sendgrid_data['sg_message_id']
    end
  end

  context "event has no message-id tracking data" do
    let(:message_id) { nil }

    context "event has sg_message_id tracking data" do
      before do
        # make sure we're finding it by the sg_message_id and not the email address
        sent_email_data.update_attribute(:to, 'null@null.com')
      end

      context "we have tracked the associated sg_message_id" do
        before do
          sent_email_data.update_attribute(:provider_message_id, sendgrid_data['sg_message_id'])
        end

        it "finds the sent email data from the sg_message_id" do
          expect(Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)).to eql [sent_email_data]
        end
      end

      context "we have not tracked the associated sg_message_id" do
        before do
          sent_email_data.update_attribute(:provider_message_id, nil)
        end

        it "finds no sent email data" do
          expect(Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)).to be_empty
        end
      end
    end

    context "event has no sg_message_id tracking data" do
      before do
        sendgrid_data['sg_message_id'] = nil
      end

      context "emails have been sent to the recipient" do
        before do
          SentEmailData.all.destroy_all
        end

        describe "one email in the last fifteen minutes" do
          it "finds the sent email data from the email address" do
            expected_email_data = [sent_email_data]
            expect(Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data).to_a).to eql expected_email_data
          end
        end

        describe "one email more than fifteen minutes ago" do
          before do
            sent_email_data.update_attribute(:created_at, Time.now-20.minutes)
          end

          it "does not find any matching email data" do
            non_matching_email_data = [sent_email_data]
            expect(Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)).to be_empty
          end
        end

        describe "multiple emails in the last fifteen minutes" do
          let(:second_sent_email_data) { create(:sent_email_data, uuid: nil, mailer_action: 'test', to: 'user@test.com') }

          it "finds all the matching sent email data" do
            expected_email_data = [sent_email_data, second_sent_email_data]
            result = Service::Email::RetrieveDataFromHeader.call(message_id, sendgrid_data: sendgrid_data)
            expect(result.length).to eq expected_email_data.length
            expected_email_data.each do |email_data|
              expect(result).to include email_data
            end
          end
        end
      end
    end
  end
end
