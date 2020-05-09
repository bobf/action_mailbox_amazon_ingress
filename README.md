# ActionMailboxAmazonIngress

Provides _Amazon SES/SNS_ integration with [_Rails ActionMailbox_](https://guides.rubyonrails.org/action_mailbox_basics.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_mailbox_amazon_ingress', '~> 0.1.0'
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

## Development

Ensure _Rubocop_, _RSpec_, and _StrongVersions_ compliance by running `make`:

```
make
```

## Contributing

Pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
