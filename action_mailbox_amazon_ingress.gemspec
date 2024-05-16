# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_mailbox_amazon_ingress/version'

Gem::Specification.new do |spec|
  spec.name          = 'action_mailbox_amazon_ingress'
  spec.version       = ActionMailboxAmazonIngress::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['git@bob.frl']
  spec.required_ruby_version = '>= 3.2'

  spec.summary       = 'Amazon SES ingress for Rails ActionMailbox'
  spec.description   = 'Integrate Amazon SES with ActionMailbox'
  spec.homepage      = 'https://github.com/bobf/action_mailbox_amazon_ingress'
  spec.license       = 'MIT'
  spec.metadata      = { 'rubygems_mfa_required' => 'true' }
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'aws-sdk-s3', '~> 1.151'
  spec.add_runtime_dependency 'aws-sdk-sns', '~> 1.75'
  spec.add_dependency 'actionmailbox', '~> 7.1'
end
