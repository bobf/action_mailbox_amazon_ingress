# frozen_string_literal: true

module ActionMailboxAmazonIngress
  class Engine < ::Rails::Engine
    config.action_mailbox.amazon = ActiveSupport::OrderedOptions.new
    initializer 'action_mailbox_amazon_ingress.mount_engine' do |app|
      app.routes.append do
        mount Engine => '/'
      end
    end
  end
end
