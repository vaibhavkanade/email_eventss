require 'virtus'

class EmailEvents::Service::ParseSmtpStatusCode < EmailEvents::Service
  include Virtus.model

  attribute :code, Integer

  def call
    smtp_code_to_simplified_status(code)
  end

  private
  def smtp_code_to_simplified_status(code)
    # return a simplified status based on the smtp status code
    if code >= 510 && code <= 512
      :email_address_invalid
    elsif code == 523
      :email_exceeds_recipients_size_limit
    elsif code == 541
      :email_rejected_as_spam
    elsif code == 552
      :recipients_inbox_is_full
    else
      :unknown
    end
  end
end
