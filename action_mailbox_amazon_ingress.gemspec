# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_mailbox_amazon_ingress/version'

Gem::Specification.new do |spec|
  spec.name          = 'action_mailbox_amazon_ingress'
  spec.version       = ActionMailboxAmazonIngress::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['git@bob.frl']
  spec.required_ruby_version = '>= 2.5'

  spec.summary       = 'Amazon SES ingress for Rails ActionMailbox'
  spec.description   = 'Integrate Amazon SES with ActionMailbox'
  spec.homepage      = 'https://github.com/bobf/action_mailbox_amazon_ingress'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'aws-sdk-sns', '~> 1.23'
  spec.add_dependency 'rails', '>= 6.1'

  spec.add_development_dependency 'devpack', '~> 0.3.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rspec-rails', '~> 4.0'
  spec.add_development_dependency 'rubocop', '~> 0.90.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'strong_versions', '~> 0.4.5'
  spec.add_development_dependency 'webmock', '~> 3.8'
end
