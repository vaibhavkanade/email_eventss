require 'spec_helper'

describe EmailEvents do
  context do "Sendgrid configured as the Rails email provider" do
    before do
      Rails.configuration.action_mailer.smtp_settings = {
        address: "smtp.sendgrid.net",
        port: '25',
        domain: "test.com",
        authentication: :plain,
        user_name: "testuser",
        password: "test123"
      }
    end

    it "applies the Sengrid adapter" do
      expect(EmailEvents.adapter).to eq :sendgrid
    end
  end
end
