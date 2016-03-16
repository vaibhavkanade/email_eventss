class CreateSentEmailData < ActiveRecord::Migration
   def change
     create_table :sent_email_data do |t|
      t.string :uuid, unique: true
      t.string :provider_message_id, :string
      t.string :mailer_class, null: false
      t.string :mailer_action,  null: false
      t.string :to, null: false
      t.text :data
      t.datetime :created_at
    end
  end
end
