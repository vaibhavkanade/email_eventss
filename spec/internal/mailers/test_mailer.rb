class TestMailer < ActionMailer::Base
  on_event :handle_event
  track_data_events :sent_email_metadata

  def mail
    mail(
      to: 'joe@test.com',
      subject: 'Test',
      from: 'sandra@test.com'
    )
  end

  private
  def handle_event(event_data, email_data)
  end

  def sent_email_metadata
    {
      arbitrary_data: true
    }
  end
end