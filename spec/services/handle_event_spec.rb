require 'spec_helper'

describe Service::Email::HandleEvent do
  def send_email_and_mock_sendgrid_event(event_type)
    TestMailer.mail.deliver_now

    @sendgrid_fixtures ||= JSON.parse(IO.read(Rails.root.join('spec','support','fixtures','sendgrid_events.json')))
    @sendgrid_fixtures[event_type].merge({
      'smtp-id' => last_email['message-id'].to_s
    }).with_indifferent_access
  end

  context "delivered event" do
    let(:sendgrid_data) { send_email_and_mock_sendgrid_event('delivered') }

    it "restores the sent_mail_data from the message-id" do
      expect(Service::Email::HandleInviteStateChange).to receive(:call) do |args|
        sent_email_data = args[:sent_email_data]
        expect(sent_email_data.data[:actor][:user_id]).to eq user.id
        expect(sent_email_data.data[:actor][:organization_id]).to eq organization.id
        expect(sent_email_data.data[:invite_id]).to eq invite.id
        expect(sent_email_data.to).to eq invite.email
      end

      Service::Email::HandleSendgridEvent.call(sendgrid_data)
    end

    it "changes the invite state to delivered" do
      Service::Email::HandleSendgridEvent.call(sendgrid_data)
      expect(invite.reload.state).to eq 'delivered'
    end
  end

  ["bounce", "dropped"].each do |event|
    context "#{event} event" do
      let(:sendgrid_data) { send_email_and_mock_sendgrid_event(event) }

      it "changes the invite state to failed" do
        Service::Email::HandleSendgridEvent.call(sendgrid_data)
        expect(invite.reload.state).to eq 'failed'
      end

      it "triggers a bounced invite notification" do
        expect(Service::Email::HandleBouncedInvite).to receive(:call)
        Service::Email::HandleSendgridEvent.call(sendgrid_data)
      end

      it "determines an error status from the smtp code" do
        expect(Service::Email::HandleBouncedInvite).to receive(:call) do |args|
          expected_status = event == 'bounce' ? :email_address_invalid : :unknown
          expect(args[:bounce_status]).to eq expected_status
        end

        Service::Email::HandleSendgridEvent.call(sendgrid_data)
      end
    end
  end

  ["deferred", "processed", "spamreport", "group_unsubscribe", "group_resubscribe"].each do |event|
    context "#{event} event" do
      let(:sendgrid_data) { send_email_and_mock_sendgrid_event(event) }

      it "does not change the invite state" do
        expect { Service::Email::HandleSendgridEvent.call(sendgrid_data) }.not_to change { invite.reload.state }
      end
    end
  end

  context "invite delivered" do
    before do
      invite.update_attribute(:state, 'delivered')
    end

    ["click", "open"].each do |event|
      context "#{event} event" do
        let(:sendgrid_data) { send_email_and_mock_sendgrid_event(event) }

        it "changes the invite state to viewed" do
          Service::Email::HandleSendgridEvent.call(sendgrid_data)
          expect(invite.reload.state).to eq 'viewed'
        end
      end
    end
  end

  context "invite already opened" do
    before do
      invite.update_attribute(:state, 'viewed')
    end

    ["click", "open"].each do |event|
      context "#{event} event" do
        let(:sendgrid_data) { send_email_and_mock_sendgrid_event(event) }

        it "keeps the state at viewed" do
          Service::Email::HandleSendgridEvent.call(sendgrid_data)
          expect(invite.reload.state).to eq 'viewed'
        end
      end
    end
  end

  context "invite already accepted" do
    before do
      invite.update_attribute(:state, 'accepted')
    end

     ["delivered", "click", "open"].each do |event|
      context "#{event} event" do
        let(:sendgrid_data) { send_email_and_mock_sendgrid_event(event) }

        it "safely ignores the late/invalid sendgrid event" do
          expect{ Service::Email::HandleSendgridEvent.call(sendgrid_data) }.not_to raise_error
          expect(invite.reload.state).to eq 'accepted'
        end
      end
    end
  end
end
