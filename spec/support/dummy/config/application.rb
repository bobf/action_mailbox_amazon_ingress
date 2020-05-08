require_relative 'boot'
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
Bundler.require(*Rails.groups)
module Dummy
  class Application < Rails::Application
    config.load_defaults 6.0
    config.api_only = true
    config.paths['db/migrate'] = 'spec/support/dummy/db/migrate'
  end
end
