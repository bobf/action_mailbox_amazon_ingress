RSpec.describe 'inbound email' do
  it 'receives inbound email' do
    post '/rails/action_mailbox/amazon/inbound_emails'
    expect(ActionMailbox::InboundEmail.count).to eql 1
  end
end
