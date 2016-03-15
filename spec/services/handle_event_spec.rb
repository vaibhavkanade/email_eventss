require 'spec_helper'

describe EmailEvents::Service::HandleEvent do
  SUPPORTED_EVENTS = {
    sendgrid: [:delivered, :bounce, :dropped, :deferred, :processed, :click, :open, :spamreport, :group_unsubscribe, :group_resubscribe],
    ses: [:delivered, :bounce, :spamreport]
  }

  let(:provider_message_id) { 'test_message_id_123' }

  [:sendgrid, :ses].each do |provider|
    context "#{provider} event" do
      before do
        EmailEvents.adapter = provider
      end

      SUPPORTED_EVENTS[provider].each do |event|
        context "#{event} event" do
          def call(event_type, provider)
            # send the email (from the TestMailer)
            allow(EmailEvents::Service::ParseSmtpResponseForProviderId).to receive(:call)
            email = TestMailer.hello.deliver_now
            EmailEvents::SentEmailData.last.update_attribute(:provider_message_id, provider_message_id)

            # get the raw provider data from the fixture
            fixture_file = File.join(File.dirname(__FILE__), "..", "fixtures", "#{provider}_events.json")
            fixtures = JSON.parse(IO.read(fixture_file))
            raw_event_data = fixtures[event_type.to_s]

            # align the ids
            case provider
            when :sendgrid
              raw_event_data['smtp-id'] = nil
              raw_event_data['sg_message_id'] = provider_message_id
            when :ses
              parsed_message_data = JSON.parse(raw_event_data['Message'])
              parsed_message_data['mail']['messageId'] = provider_message_id
              raw_event_data['Message'] = parsed_message_data.to_json
            end

            # call the service
            EmailEvents::Service::HandleEvent.call(raw_event_data)
          end

          it "triggers the mailer's on_event handler" do
            expect_any_instance_of(TestMailer).to receive(:handle_event)
            call(event, provider)
          end

          it "provides the callback with the event details" do
            expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
              expect(event_data.event_type).to eq event
            end
            call(event, provider)
          end

          it "provides the callback with the original email details" do
            expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
              expect(email_data.to).to eq 'joe@test.com'
            end
            call(event, provider)
          end

          it "provides the callback with the custom tracked metadata" do
            expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
              expect(email_data.data[:arbitrary_data]).to eq true
            end
            call(event, provider)
          end
        end
      end
    end
  end
end
