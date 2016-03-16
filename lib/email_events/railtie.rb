require 'rails'

module EmailEvents
  class Railtie < Rails::Railtie
    initializer 'email_events.initialize', after: :load_config_initializers do
      ActiveSupport.on_load(:action_mailer) do
        include EmailEvents::Mailer
      end

      # Gridhook gets upset when it draws its routes if we haven't setup the event receive path, so always do so here immediately
      # (even when sendgrid is not used)
      # TODO: especially if there ever gets to be > 2 adapters, each adapters should ideally be broken out into its own gem
      Gridhook.config.event_receive_path = '/email_events/null'
      Gridhook.config.event_processor = Proc.new { raise 'Sendgrid adapter not loaded' }

      EmailEvents.initialize
    end
  end
end
