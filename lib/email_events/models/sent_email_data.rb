require 'active_record'

# == Schema Information
#
# Table name: sent_email_data
#
#  id            :integer          not null, primary key
#  uuid          :string
#  mailer_class  :string
#  mailer_action :string           not null
#  to            :string           not null
#  data          :text
#  created_at    :datetime
#  provider_message_id :string

module EmailEvents
  class SentEmailData < ActiveRecord::Base
    attr_accessible :uuid, :mailer_class, :mailer_action, :to, :data
    serialize :data
  end
end
