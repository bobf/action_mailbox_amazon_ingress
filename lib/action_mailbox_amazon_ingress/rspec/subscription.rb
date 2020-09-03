# frozen_string_literal: true

module ActionMailboxAmazonIngress
  module RSpec
    class Subscription
      def initialize(authentic: true, topic: 'topic:arn:default')
        @authentic = authentic
        @topic = topic
      end

      def url
        '/rails/action_mailbox/amazon/inbound_emails'
      end

      def headers
        { 'content-type' => 'application/json' }
      end

      def params
        {
          'Type' => 'SubscriptionConfirmation',
          'TopicArn' => @topic,
          'SubscribeURL' => 'http://example.com/subscribe'
        }
      end

      def authentic?
        @authentic
      end
    end
  end
end
