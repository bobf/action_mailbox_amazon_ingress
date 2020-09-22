# ActionMailboxAmazonIngress

Provides _Amazon SES/SNS_ integration with [_Rails ActionMailbox_](https://guides.rubyonrails.org/action_mailbox_basics.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_mailbox_amazon_ingress', '~> 0.1.1'
```

## Configuration

### Amazon SES/SNS

Configure _SES_ to [route emails through SNS](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/configure-sns-notifications.html).

If your website is hosted at https://www.example.com then configure _SNS_ to publish the _SES_ notification topic to this _HTTP_ endpoint:

https://example.com/rails/action_mailbox/amazon/inbound_emails

### Rails

Configure _ActionMailbox_ to accept emails from Amazon SES:

```
# config/environments/production.rb
config.action_mailbox.ingress = :amazon
```

Configure which _SNS_ topics will be accepted:

```
# config/environments/production.rb
config.action_mailbox.amazon.subscribed_topics = %w(
  arn:aws:sns:eu-west-1:123456789001:example-topic-1
  arn:aws:sns:us-east-1:123456789002:example-topic-2
)
```

Subscriptions will now be auto-confirmed and messages will be delivered via _ActionMailbox_.

Note that even if you manually confirm subscriptions you will still need to provide a list of subscribed topics; messages from unrecognized topics will be ignored.

See [ActionMailbox documentation](https://guides.rubyonrails.org/action_mailbox_basics.html) for full usage information.

## Testing

### RSpec

Two _RSpec_ _request spec_ helpers are provided to facilitate testing _Amazon SNS/SES_ notifications in your application:

* `amazon_ingress_deliver_subscription_confirmation`
* `amazon_ingress_deliver_email`

Include the `ActionMailboxAmazonIngress::RSpec` extension in your tests:

```ruby
# spec/rails_helper.rb

require 'action_mailbox_amazon_ingress/rspec'

RSpec.configure do |config|
  config.include ActionMailboxAmazonIngress::RSpec
end
```

Configure your _test_ environment to accept the default topic used by the provided helpers:

```ruby
# config/environments/test.rb

config.action_mailbox.amazon.subscribed_topics = ['topic:arn:default']
```

#### Example Usage

```ruby
# spec/requests/amazon_emails_spec.rb

RSpec.describe 'amazon emails', type: :request do
  it 'delivers a subscription notification' do
    amazon_ingress_deliver_subscription_confirmation
    expect(response).to have_http_status :ok
  end

  it 'delivers an email notification' do
    amazon_ingress_deliver_email(mail: Mail.new(to: 'user@example.com'))
    expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
  end
end
```

You may also pass the following keyword arguments to both helpers:

* `topic`: The _SNS_ topic used for each notification (default: `topic:arn:default`).
* `authentic`: The `Aws::SNS::MessageVerifier` class is stubbed by these helpers; set `authentic` to `true` or `false` to define how it will verify incoming notifications (default: `true`).

## Development

Ensure _Rubocop_, _RSpec_, and _StrongVersions_ compliance by running `make`:

```
make
```

## Contributing

Pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
