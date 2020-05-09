# frozen_string_literal: true

RSpec.describe 'inbound email' do
  before do
    stub_request(
      :get,
      'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-a86cb10b4e1f29c941702d737128f7b6.pem'
    ).and_return(body: fixture(:certificate, :pem))
  end

  it 'receives inbound email' do
    body = fixture(:inbound_email, :json)
    post '/rails/action_mailbox/amazon/inbound_emails', params: body
    expect(ActionMailbox::InboundEmail.count).to eql 1
  end
end
