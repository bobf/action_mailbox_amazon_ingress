Rails.application.configure do
  config.active_storage.service = :test
  config.action_mailbox.ingress = :amazon
  config.action_mailbox.amazon.subscribed_topics = %w(
    arn:aws:sns:eu-west-1:111111111111:example-topic
    arn:aws:sns:eu-west-1:111111111111:recognized-topic
  )
  config.eager_load = false
end
