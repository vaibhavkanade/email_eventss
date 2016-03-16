class TestMailer < ActionMailer::Base
  on_event :handle_event
  track_data :sent_email_metadata

  def hello
    mail(
      to: 'joe@test.com',
      subject: 'Hello',
      from: 'sandra@test.com'
    ) do |format|
      format.text { render text: 'Hello Joe, From Sandra' }
    end
  end

  private
  def handle_event(event_data, email_data)
    'aoeu'
  end

  def sent_email_metadata
    {
      arbitrary_data: true
    }
  end
end