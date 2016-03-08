module EmailEvents::Adapters
  module Abstract
    class EventData
      [:event_type, :status_string, :smtp_status_code, :reason, :provider_message_id].each do |pure_virtual_method|
        define_method(pure_virtual_method) do
          raise "Not implemented"
        end
      end
    end
  end
end
