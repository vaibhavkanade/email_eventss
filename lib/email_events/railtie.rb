require 'rails'

module EmailEvents
  class Railtie < Rails::Railtie
    initializer 'email_events.initialize' do
      ActiveSupport.on_load(:action_mailer) do
        include EmailEvents::Mailer
      end

      EmailEvents.initialize
    end
  end
end
