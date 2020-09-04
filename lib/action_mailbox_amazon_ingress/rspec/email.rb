# frozen_string_literal: true

module ActionMailboxAmazonIngress
  module RSpec
    class Email
      def initialize(authentic: true, topic: 'topic:arn:default', mail: default_mail)
        @authentic = authentic
        @topic = topic
        @mail = mail
      end

      def headers
        { 'content-type' => 'application/json' }
      end

      def url
        '/rails/action_mailbox/amazon/inbound_emails'
      end

      def params
        {
          'Type' => 'Notification',
          'TopicArn' => @topic,
          'Message' => {
            'notificationType' => 'Received',
            'content' => @mail.encoded
          }.to_json
        }
      end

      def authentic?
        @authentic
      end

      def default_mail
        Mail.new
      end
    end
  end
end
