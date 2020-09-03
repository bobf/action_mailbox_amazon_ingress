# frozen_string_literal: true

require 'action_mailbox_amazon_ingress/rspec/email'
require 'action_mailbox_amazon_ingress/rspec/subscription'

module ActionMailboxAmazonIngress
  module RSpec
    def amazon_ingress_deliver_subscription(options = {})
      subscription = Subscription.new(**options)
      stub_aws_sns_message_verifier(subscription)
      stub_aws_sns_subscription_request
      post subscription.url, params: subscription.params.to_json, headers: subscription.headers
    end

    def amazon_ingress_deliver_email(options = {})
      email = Email.new(**options)
      stub_aws_sns_message_verifier(email)
      post email.url, params: email.params.to_json, headers: email.headers
    end

    private

    def message_verifier(subscription)
      instance_double(Aws::SNS::MessageVerifier, authentic?: subscription.authentic?)
    end

    def stub_aws_sns_message_verifier(notification)
      allow(Aws::SNS::MessageVerifier).to receive(:new) { message_verifier(notification) }
    end

    def stub_aws_sns_subscription_request
      allow(Net::HTTP).to receive(:get_response).and_call_original
      allow(Net::HTTP)
        .to receive(:get_response)
          .with(URI('http://example.com/subscribe')) { double(code: '200') }
    end
  end
end
