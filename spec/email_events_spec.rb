require 'spec_helper'

describe EmailEvents do
  context "Sendgrid is configured as the Rails email provider" do
    # this is the default set in the spec_helper

    it "auto-detects Sendgrid to use as the adapter based on the smtp settings" do
      expect(EmailEvents.adapter).to eq EmailEvents::Adapters::Sendgrid
    end
  end
end
