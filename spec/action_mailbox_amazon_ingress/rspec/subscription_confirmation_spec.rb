# frozen_string_literal: true

RSpec.describe ActionMailboxAmazonIngress::RSpec::SubscriptionConfirmation do
  subject(:subscription) { described_class.new(**options) }
  let(:options) { { authentic: authentic } }

  let(:authentic) { true }
  let(:topic) { 'topic:arn:default' }
  let(:expected_params) do
    {
      'Type' => 'SubscriptionConfirmation',
      'TopicArn' => topic,
      'SubscribeURL' => 'http://example.com/subscribe'
    }
  end

  it { is_expected.to be_a described_class }
  its(:url) { is_expected.to eql '/rails/action_mailbox/amazon/inbound_emails' }
  its(:headers) { is_expected.to eql('content-type' => 'application/json') }
  its(:params) { is_expected.to eql(expected_params) }

  context 'not authentic' do
    let(:authentic) { false }
    its(:authentic?) { is_expected.to eql false }
  end

  context 'authentic' do
    let(:authentic) { true }
    its(:authentic?) { is_expected.to eql true }
  end

  context 'custom topic' do
    subject { described_class.new(topic: topic) }
    let(:topic) { 'custom-topic' }
    its(:params) { is_expected.to include('TopicArn' => topic) }
  end
end
