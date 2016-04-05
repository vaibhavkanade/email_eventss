# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_events/version'

Gem::Specification.new do |spec|
  spec.name          = "email_events"
  spec.version       = EmailEvents::VERSION
  spec.authors       = ["Kent Mewhort @ Coupa"]
  spec.email         = ["kent.mewhort@coupa.com"]

  spec.summary       = %q{Email event handling for delivery, bounces, drops, replies, etc.}
  spec.description   = %q{Supports handling incoming events for SES/SNS or Sendgrid}
  spec.homepage      = "https://github.com/coupa/email_events"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'
  spec.add_dependency "gridhook"
  spec.add_dependency "sns_endpoint"
  spec.add_dependency "uuidtools"
  spec.add_dependency "virtus"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3", "~> 1.0"
  spec.add_development_dependency "combustion", "~> 0.5.0"
end
