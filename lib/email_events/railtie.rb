require 'rails'

module EmailEvents
  class Railtie < Rails::Railtie
    initializer 'email_events.initialize', after: :load_config_initializers do
      ActiveSupport.on_load(:action_mailer) do
        include EmailEvents::Mailer
      end

      EmailEvents.initialize

      # Gridhook gets upset when it draws its routes if we haven't setup the event receive path, so always do so here immediately
      # (even for non-sendgrid)
      # TODO: should ideally break out the adapters into separate gems
      Gridhook.config.event_receive_path = '/email_events/sendgrid'
    end
  end
end
