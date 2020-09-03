# frozen_string_literal: true

RSpec.describe ActionMailboxAmazonIngress::RSpec::Email do
  subject(:email) { described_class.new(**options) }

  it { is_expected.to be_a described_class }

  let(:options) { { authentic: authentic, mail: mail } }
  let(:authentic) { true }
  let(:mail) { instance_double(Mail::Message, encoded: 'raw encoded email') }
  let(:expected_params) do
    {
      'Type' => 'Notification',
      'TopicArn' => 'topic:arn:default',
      'Message' => {
        'notificationType' => 'Received',
        'content' => 'raw encoded email'
      }.to_json
    }
  end

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
