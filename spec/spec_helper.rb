# frozen_string_literal: true

require 'bundler/setup'
require 'action_mailbox_amazon_ingress'
require 'devpack'
require 'webmock/rspec'
require 'rails'
require 'action_controller/railtie'
require 'rspec/rails'
require 'rspec/its'
require 'action_mailbox_amazon_ingress/rspec'

ENV['RAILS_ENV'] = 'production'
ENV['SECRET_KEY_BASE'] = 'test-secret-key-base'

require File.join(__dir__, 'support', 'dummy', 'config', 'environment.rb')

ActiveRecord::Base.connection.migration_context.migrate

module FixtureHelper
  def fixture(name, type)
    root = ActionMailboxAmazonIngress.root
    File.read(root.join('spec', 'fixtures', type.to_s, "#{name}.#{type}"))
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
  config.before { ActionMailbox::InboundEmail.destroy_all }
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.infer_spec_type_from_file_location!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
