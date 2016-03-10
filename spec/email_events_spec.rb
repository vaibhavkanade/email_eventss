require 'spec_helper'

describe EmailEvents do
  context "Sendgrid is configured as the Rails email provider" do
    # this is the default set in the spec_helper

    it "detects Sendgrid to use as the adapter" do
      expect(EmailEvents.adapter).to eq EmailEvents::Adapters::Sendgrid
    end
  end
end
