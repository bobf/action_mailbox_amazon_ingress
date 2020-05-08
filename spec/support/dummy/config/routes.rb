require 'action_mailbox_amazon_ingress'

Rails.application.routes.draw do
  mount ActionMailboxAmazonIngress::Engine, at: '/'
end
