# frozen_string_literal: true

require 'aws-sdk-sns'

module ActionMailboxAmazonIngress
  class SnsNotification
    class MessageContentError < StandardError; end

    def initialize(request_body)
      @request_body = request_body
    end

    def subscription_confirmed?
      confirmation_response.code&.start_with?('2')
    end

    def verified?
      Aws::SNS::MessageVerifier.new.authentic?(@request_body)
    end

    def topic
      notification.fetch(:TopicArn)
    end

    def type
      notification.fetch(:Type)
    end

    def message_content
      raise MessageContentError, 'Incoming emails must have notificationType `Received`' unless receipt?

      if content_in_s3?
        s3_content
      else
        return message[:content] unless destination

        "X-Original-To: #{destination}\n#{message[:content]}"
      end
    end

    private

    def notification
      @notification ||= JSON.parse(@request_body, symbolize_names: true)
    rescue JSON::ParserError => e
      Rails.logger.warn("Unable to parse SNS notification: #{e}")
      nil
    end

    def s3_content
      require 'aws-sdk-s3'

      Aws::S3::Client
        .new(region: region)
        .get_object(key: key, bucket: bucket)
        .body
        .string
    end

    def message
      @message ||= JSON.parse(notification[:Message], symbolize_names: true)
    end

    def destination
      message.dig(:mail, :destination)&.first
    end

    def action
      return unless message[:receipt]

      message.fetch(:receipt).fetch(:action)
    end

    def bucket
      action.fetch(:bucketName)
    end

    def region
      action.fetch(:topicArn).split(':')[3]
    end

    def key
      action.fetch(:objectKey)
    end

    def content_in_s3?
      action&.fetch(:type) == 'S3'
    end

    def receipt?
      message.fetch(:notificationType) == 'Received'
    end

    def confirmation_response
      @confirmation_response ||= Net::HTTP.get_response(URI(notification[:SubscribeURL]))
    end
  end
end
