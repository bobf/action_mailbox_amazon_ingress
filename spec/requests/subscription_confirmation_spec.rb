# frozen_string_literal: true

RSpec.describe 'subscription confirmation' do
  def fixture(name, type)
    root = ActionMailboxAmazonIngress.root
    File.read(root.join('spec', 'fixtures', type.to_s, "#{name}.#{type}"))
  end

  let!(:subscription_confirmation_request) do
    query = Rack::Utils.build_query(subscription_params)
    stub_request(:get, "https://sns.eu-west-1.amazonaws.com/?#{query}")
  end

  before do
    stub_request(
      :get,
      'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem'
    ).and_return(body: fixture(:certificate, :pem))
  end

  let(:subscription_params) do
    {
      Action: 'ConfirmSubscription',
      Token: 'abcd1234' * 32,
      TopicArn: 'arn:aws:sns:eu-west-1:111111111111:example-topic'
    }
  end

  let(:action) do
    post '/rails/action_mailbox/amazon/inbound_emails',
         params: fixture(type, :json)
  end

  context 'valid Amazon SSL signature' do
    let(:type) { 'valid_signature' }
    it 'fetches subscription URL' do
      action
      expect(subscription_confirmation_request).to have_been_requested
    end
  end

  context 'invalid Amazon SSL signature' do
    let(:type) { 'invalid_signature' }
    it 'does not fetch subscription URL' do
      action
      expect(subscription_confirmation_request).to_not have_been_requested
    end
  end
end
