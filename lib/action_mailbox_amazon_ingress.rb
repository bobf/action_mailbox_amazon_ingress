# frozen_string_literal: true

require 'pathname'
require 'net/http'
require 'rails'
require 'action_mailbox/engine'
require 'aws-sdk-sns'

require 'action_mailbox_amazon_ingress/engine'
require 'action_mailbox_amazon_ingress/version'

module ActionMailboxAmazonIngress
  class Error < StandardError; end

  def self.root
    Pathname.new(File.expand_path(File.join(__dir__, '..')))
  end
end
