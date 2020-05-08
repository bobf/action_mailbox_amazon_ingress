# frozen_string_literal: true

module ActionMailbox
  module Ingresses
    module Amazon
      class InboundEmailsController < ActionMailbox::BaseController
        before_action :verify_authenticity
        before_action :confirm_subscription

        def create
          ActionMailbox::InboundEmail.create_and_extract_message_id!(mail)
        end

        private

        def verify_authenticity
          head :bad_request unless notification.present?
          head :unauthorized unless verified?
        end

        def confirm_subscription
          return unless notification['Type'] == 'SubscriptionConfirmation'
          return head :ok if confirmation_response_code&.start_with?('2')

          Rails.logger.error('Unable to confirm subscription.')
          head :internal_server_error
        end

        def confirmation_response_code
          @confirmation_response_code ||= begin
            Net::HTTP.get_response(URI(notification['SubscribeURL'])).code
          end
        end

        def notification
          @notification ||= JSON.parse(request.body.read)
        rescue JSON::ParserError => e
          Rails.logger.warn("Unable to parse message: #{e}")
          nil
        end

        def verified?
          verifier = Aws::SNS::MessageVerifier.new
          verifier.authentic?(@notification.to_json)
        end

        def mail
          # TODO
        end
      end
    end
  end
end
