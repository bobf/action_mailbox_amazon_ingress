Rails.application.configure do
  config.action_mailbox.ingress = :amazon
  config.eager_load = false
end
