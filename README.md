# EmailEvents

EmailEvents handles incoming events for your emails: bounces, drops, delivery, link clicks, and replies. It aims to do
this in a provider agnostic way.  Currently supports Sengrid and AWS.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'email_events'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email_events
    
Then install the migration for tracking sent emails:
    
    $ rails g email_events:install
    
### Rails configuration

1. Setup your action_mailer smtp settings as usual. Email_events will detect whether your using Sendgrid SES based on the
smtp address, but you can also set the adapter in an initializer -- eg. `EmailEvents.provider = :sendgrid`.

2. **Important**: Set `config.action_mailer.smtp_settings[:return_response] = true`. This is necessary to get the email
provider's unique ids back for tracking events against the original email.

    
### Sendgrid

1. Login to your SendGrid account and navigate to "Mail Settings" -> Event Notification.

2. Turn the module "On".

3. Set the HTTP POST URL to https://<yourdomain>/email_events/sendgrid

4. Under "Select Actions", choose the event types for which you would like to receive triggers.

That's it!

### AWS SES / SNS    

1. Login to the AWS Management Console.

2. Open up the AWS SNS console.

3. Click "Create Topic".  Set both the the "Topic name" to "email_events" and the "Display name" to "emails". Click "Create topic".

4. In the "Topic Details", click "Create Subscription".  Set the endpoint to https://<yourdomain>/email_events/ses

5. Open up the AWS SES console.

6. Under either "Domains" or "Email Addresses" (depending on whether you want event triggers for an entire domain or individual
senders), click on a domain or email adress, then click "Details" and expand the "Notifications" tab.

7. Click Edit Configuration and set the SNS Topic to "email_events" for Bounces, Complaints, and/or Deliveries.

8. At the moment, you need to mount the sns_endpoint gem engine which email_events uses (yes, a nice-to-have would be for
 email_events to just act as an engine itself).  Put `mount SnsEndpoint::Core => '/email_events/ses'` in your routes.rb.

## Usage

### Basic

Simply add an `on_event` handler to your mailer to start handling email events.  Eg.:

```
class MyMailer < ActionMailer::Base
  on_event :handle_event

  ...
  
  
  def handle_event(event_data, email_data)
    if event_data.event_type == :bounce
      my_bounce_notification_method(email_data.to)
    end     
  end
end
```

### Supported Event Types

- For Sendgrid: :delivered, :bounce, :dropped, :deferred, :processed, :click, :open, :spamreport, :group_unsubscribe, :group_resubscribe
- For AWS: :delivered, :bounce, :spamreport

### Advanced

You can track custom JSON data along with the original email message.  This data will then be available to you in the event
handler:

```
class MyMailer < ActionMailer::Base
  on_event :handle_event
  track_data :custom_metadata

  ...
  
  def custom_metadata
    {
      my_data: true
    }
  end
  
  def handle_event(event_data, email_data)
    my_data = email_data.data[:my_data] 
    ...
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coupa/email_events.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

