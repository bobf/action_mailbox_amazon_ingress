# ActionMailboxAmazonIngress

Provides _Amazon SES/SNS_ integration with [_Rails ActionMailbox_](https://guides.rubyonrails.org/action_mailbox_basics.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_mailbox_amazon_ingress', '~> 0.1.3'
```

## Configuration

### Amazon SES/SNS

1. [Configure SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications.html) to (save emails to S3)(https://docs.aws.amazon.com/ses/latest/dg/receiving-email-action-s3.html) or to send them as raw messages.

2. [Configure the SNS topic for SES or for the S3 action](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-action-sns.html) to send notifications to +/rails/action_mailbox/amazon/inbound_emails+. For example, if your website is hosted at https://www.example.com then configure _SNS_ to publish the _SES_ notification topic to this _HTTP_ endpoint: https://example.com/rails/action_mailbox/amazon/inbound_emails

### Rails

1. Configure _ActionMailbox_ to accept emails from Amazon SES:

```
# config/environments/production.rb
config.action_mailbox.ingress = :amazon
```

2. Configure which _SNS_ topics will be accepted:

```
# config/environments/production.rb
config.action_mailbox.amazon.subscribed_topics = %w(
  arn:aws:sns:eu-west-1:123456789001:example-topic-1
  arn:aws:sns:us-east-1:123456789002:example-topic-2
)
```

SNS Subscriptions will now be auto-confirmed and messages will be automatically handled via _ActionMailbox_.

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

### Setup

`bin/setup`

### Testing

Ensure _Rubocop_, _RSpec_, and _StrongVersions_ compliance by running `make`:

```
make
```
### Updating AWS Fixtures

`bundle exec rake sign_aws_fixtures`

## Contributing

Pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
