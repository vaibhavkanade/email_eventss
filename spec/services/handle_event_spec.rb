require 'spec_helper'

describe EmailEvents::Service::HandleEvent do
  context 'Sendgrid event' do
    [:delivered, :bounce, :dropped, :deferred, :processed, :click, :open, :spamreport,
     :group_unsubscribe, :group_resubscribe].each do |event|
      context "#{event} event" do

        def call(event_type)
          # send the email (from the TestMailer)
          email = TestMailer.hello.deliver_now

          # get the raw sendgrid data from the fixture and align the smtp message-id
          fixture_file = File.join(File.dirname(__FILE__), "..", "fixtures", "sendgrid_events.json")
          sendgrid_fixtures ||= JSON.parse(IO.read(fixture_file))
          raw_event_data = sendgrid_fixtures[event_type.to_s].merge({
            'smtp-id' => email.header['message-id'].to_s
          }).with_indifferent_access

          # call the service
          EmailEvents::Service::HandleEvent.call(raw_event_data)
        end

        it "triggers the mailer's on_event handler" do
          expect_any_instance_of(TestMailer).to receive(:handle_event)
          call(event)
        end

        it "provides the callback with the event details" do
          expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
            expect(event_data.event_type).to eq event
          end
          call(event)
        end

        it "provides the callback with the original email details" do
          expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
            expect(email_data.to).to eq 'joe@test.com'
          end
          call(event)
        end

        it "provides the callback with the custom tracked metadata" do
          expect_any_instance_of(TestMailer).to receive(:handle_event) do |instance, event_data, email_data|
            expect(email_data.data[:arbitrary_data]).to eq true
          end
          call(event)
        end
      end
    end
  end
end
