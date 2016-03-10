require 'spec_helper'

describe EmailEvents do
  context "Sendgrid is configured as the Rails email provider" do
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

    it "detects Sendgrid to use as the adapter" do
      expect(EmailEvents.provider).to eq :sendgrid
    end
  end
end
