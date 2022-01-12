# frozen_string_literal: true

RSpec.describe 'rspec' do
  before do
    allow(Rails.configuration.action_mailbox.amazon).to receive(:subscribed_topics) { topic }
  end

  include ActionMailboxAmazonIngress::RSpec

  describe 'topic subscription' do
    context 'recognized topic' do
      let(:topic) { 'topic:arn:default' }
      it 'renders 200 OK' do
        amazon_ingress_deliver_subscription_confirmation
        expect(response).to have_http_status :ok
      end
    end

    context 'unrecognized topic' do
      let(:topic) { 'topic:arn:other' }
      it 'renders 401 Unauthorized' do
        amazon_ingress_deliver_subscription_confirmation
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'email delivery' do
    context 'recognized topic' do
      let(:topic) { 'topic:arn:default' }
      it 'renders 204 No Content' do
        amazon_ingress_deliver_email(mail: Mail.new)
        expect(response).to have_http_status :no_content
      end

      it 'delivers an email to inbox' do
        amazon_ingress_deliver_email(mail: Mail.new(to: 'user@example.com'))
        expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
      end
    end

    context 'unrecognized topic' do
      let(:topic) { 'topic:arn:other' }
      it 'renders 401 Unauthorized' do
        amazon_ingress_deliver_email
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with destination parameter set' do
      let(:topic) { 'topic:arn:default' }

      it 'extracts recipient email from SNS notification content' do
        amazon_ingress_deliver_email(
          mail: Mail.new,
          message_params: { 'mail' => { 'destination' => 'user@example.com' } }
        )

        expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
      end
    end
  end
end
