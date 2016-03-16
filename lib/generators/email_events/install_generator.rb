require "rails/generators/active_record"

module EmailEvents
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration
    desc "Generates migration for email_events"

    source_paths << File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "create_sent_email_data.rb", "db/migrate/create_sent_email_data.rb"
    end

    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end
  end
end
