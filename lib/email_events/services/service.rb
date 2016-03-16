# use a Service Objects architecture
class EmailEvents::Service
  def self.call(*args, &block)
    if block_given?
      new(*args).call(&block)
    else
      new(*args).call
    end
  end
end
