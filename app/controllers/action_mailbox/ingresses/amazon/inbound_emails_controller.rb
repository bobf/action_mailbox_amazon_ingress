# frozen_string_literal: true

module ActionMailbox
  # Ingests inbound emails from Amazon SES/SNS and confirms subscriptions.
  #
  # Subscription requests must provide the following parameters in a JSON body:
  # - +Message+: Notification content
  # - +MessagId+: Notification unique identifier
  # - +Timestamp+: iso8601 timestamp
  # - +TopicArn+: Topic identifier
  # - +Type+: Type of event ("Subscription")
  #
  # Inbound email events must provide the following parameters in a JSON body:
  # - +Message+: Notification content
  # - +MessagId+: Notification unique identifier
  # - +Timestamp+: iso8601 timestamp
  # - +SubscribeURL+: Topic identifier
  # - +TopicArn+: Topic identifier
  # - +Type+: Type of event ("SubscriptionConfirmation")
  #
  # All requests are authenticated by validating the provided AWS signature.
  #
  # Returns:
  #
  # - <tt>204 No Content</tt> if a request is successfully processed
  # - <tt>401 Unauthorized</tt> if a request does not contain a valid signature
  # - <tt>404 Not Found</tt> if the Amazon ingress has not been configured
  # - <tt>422 Unprocessable Entity</tt> if a request provides invalid parameters
  #
  # == Usage
  #
  # 1. Tell Action Mailbox to accept emails from Amazon SES:
  #
  #        # config/environments/production.rb
  #        config.action_mailbox.ingress = :amazon
  #
  # 2. Configure which SNS topics will be accepted:
  #
  #        config.action_mailbox.amazon.subscribed_topics = %w(
  #          arn:aws:sns:eu-west-1:123456789001:example-topic-1
  #          arn:aws:sns:us-east-1:123456789002:example-topic-2
  #        )
  #
  # 3. {Configure SES}[https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications.html]
  #    to route emails through SNS.
  #
  #    Configure SNS to send emails to +/rails/action_mailbox/amazon/inbound_emails+.
  #
  #    If your application is found at <tt>https://example.com</tt> you would
  #    specify the fully-qualified URL <tt>https://example.com/rails/action_mailbox/amazon/inbound_emails</tt>.
  #

  module Ingresses
    module Amazon
      class InboundEmailsController < ActionMailbox::BaseController
        before_action :verify_authenticity
        before_action :validate_topic
        before_action :confirm_subscription

        def create
          if mail.present?
            Rails.logger.info{"[action_mailbox_amazon_ingress] Inbound email received."}
            ActionMailbox::InboundEmail.create_and_extract_message_id!(mail)
            head :no_content
          else
            Rails.logger.info{"[action_mailbox_amazon_ingress] Inbound email ignored (mail object missing)."}
            head :bad_request
          end
        end

        private

        def verify_authenticity
          head :bad_request unless notification.present?
          head :unauthorized unless verified?
        end

        def confirm_subscription
          return unless notification['Type'] == 'SubscriptionConfirmation'
          return head :ok if confirmation_response_code&.start_with?('2')

          Rails.logger.error{'SNS subscription confirmation request rejected.'}
          head :unprocessable_entity
        end

        def validate_topic
          return if valid_topics.include?(topic)

          Rails.logger.info{"Ignoring unknown topic: #{topic}"}
          head :unauthorized
        end

        def confirmation_response_code
          @confirmation_response_code ||= begin
            Rails.logger.info{"[action_mailbox_amazon_ingress] Confirming SNS subscription for topic"}
            response_code = Net::HTTP.get_response(URI(notification['SubscribeURL'])).code
            Rails.logger.info{"[action_mailbox_amazon_ingress] Confirmed SNS subscription for topic with response code #{response_code}"}
          end
        end

        def notification
          unless @notification
            @notification = JSON.parse(request.body.read)
            Rails.logger.debug{"[action_mailbox_amazon_ingress] SNS notification successfully parsed."}
          end
          @notification
        rescue JSON::ParserError => e
          Rails.logger.warn{"[action_mailbox_amazon_ingress] Unable to parse SNS notification: #{e}"}
          nil
        end

        def verified?
          verifier.authentic?(@notification.to_json)
          Rails.logger.debug{"[action_mailbox_amazon_ingress] SNS notification verified."}
        rescue => e
          Rails.logger.info{"[action_mailbox_amazon_ingress] Unable to verify SNS authenticity: #{e}"}
          false
        end

        def verifier
          Aws::SNS::MessageVerifier.new
        end

        def s3
          bucket_name = receipt.dig("action", "bucketName")
          object_key_prefix = receipt.dig("action", "objectKeyPrefix")
          object_key = receipt.dig("action", "objectKey")
          key = [object_key_prefix, object_key].compact_blank.join("/")

          Rails.logger.debug{"[action_mailbox_amazon_ingress] Downloading S3 object #{key} from bucket #{bucket_name}"}
          s3_client = Aws::S3::Client.new
          s3_object = s3_client.get_object(bucket: bucket_name, key: key)

          # if the email was encrypted
          if kms_cmk_id = JSON.parse(s3_object.metadata['x-amz-matdesc'])['kms_cmk_id']
            Rails.logger.debug{"[action_mailbox_amazon_ingress] Decrypting S3 object #{key} from bucket #{bucket_name} with KMS CMK #{kms_cmk_id}"}
            s3_encryption_client = Aws::S3::EncryptionV2::Client.new(client: s3_client, kms_key_id: kms_cmk_id, key_wrap_schema: :kms_context, content_encryption_schema: :aes_gcm_no_padding, security_profile: :v2_and_legacy)
            s3_object = s3_encryption_client.get_object(bucket: bucket_name, key: key)
          else
            Rails.logger.debug{"[action_mailbox_amazon_ingress] S3 object #{key} from bucket #{bucket_name} is not encrypted"}
          end

          Rails.logger.debug{"[action_mailbox_amazon_ingress] S3 object #{key} from bucket #{bucket_name} successfully downloaded"}
          email_content = s3_object.body.read

          Rails.logger.debug{"[action_mailbox_amazon_ingress] Deleteing S3 object #{key} from bucket #{bucket_name}"}
          s3_client.delete_object(bucket: bucket_name, key: key)

          Rails.logger.debug{"[action_mailbox_amazon_ingress] S3 object #{key} from bucket #{bucket_name} successfully deleted"}

          return email_content
        rescue Aws::S3::Errors::ServiceError => e
          Rails.logger.error(e)
          return nil
        end

        def message
          @message ||= JSON.parse(notification['Message'])
        end

        def receipt
          @receipt ||= message['receipt']
        end

        def mail
          return @mail if @mail
          return nil unless notification['Type'] == 'Notification'
          return @mail = s3 if receipt.dig('action', 'type') == 'S3'
          return nil unless message['notificationType'] == 'Received'
          return @mail = message['content']
        end

        def topic
          return nil unless notification.present?

          notification['TopicArn']
        end

        def valid_topics
          ::Rails.configuration.action_mailbox.amazon.subscribed_topics
        end
      end
    end
  end
end
