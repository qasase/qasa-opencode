# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "qasa-opencode"
  spec.version = "0.4.0"
  spec.authors = ["Qasa"]
  spec.summary = "Read-only OpenCode wrapper for Qasa business staff"
  spec.description = "CLI tool that wraps OpenCode to give non-technical staff safe, read-only access to query business logic across frontend and backend repos."
  spec.homepage = "https://github.com/qasase/qasa-opencode"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb", "bin/*", "templates/**/*"]
  spec.bindir = "bin"
  spec.executables = ["qasa-opencode"]

  spec.add_dependency "thor", "~> 1.0"
end
