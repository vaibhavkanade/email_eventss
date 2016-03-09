# use a Service Objects architecture

require 'virtus'

class EmailEvents::Service
  include Virtus.model

  def self.call(*args, &block)
    if block_given?
      new(*args).call(&block)
    else
      new(*args).call
    end
  end
end