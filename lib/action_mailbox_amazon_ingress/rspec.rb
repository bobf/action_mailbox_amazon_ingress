# frozen_string_literal: true

require 'action_mailbox_amazon_ingress/rspec/email'
require 'action_mailbox_amazon_ingress/rspec/subscription_confirmation'

module ActionMailboxAmazonIngress
  module RSpec
    def amazon_ingress_deliver_subscription_confirmation(options = {})
      subscription_confirmation = SubscriptionConfirmation.new(**options)
      stub_aws_sns_message_verifier(subscription_confirmation)
      stub_aws_sns_subscription_request

      post subscription_confirmation.url,
           params: subscription_confirmation.params,
           headers: subscription_confirmation.headers,
           as: :json
    end

    def amazon_ingress_deliver_email(options = {})
      email = Email.new(**options)
      stub_aws_sns_message_verifier(email)

      post email.url,
           params: email.params,
           headers: email.headers,
           as: :json
    end

    private

    def message_verifier(subscription_confirmation)
      instance_double(Aws::SNS::MessageVerifier, authentic?: subscription_confirmation.authentic?)
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
