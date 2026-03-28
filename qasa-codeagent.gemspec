# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "qasa-codeagent"
  spec.version = "1.0.0"
  spec.authors = ["Qasa"]
  spec.summary = "AI coding agent wrapper for non-technical staff"
  spec.description = "CLI tool that gives non-technical staff safe, read-only access to query business logic across repositories using Claude Code, OpenCode, or any AI coding agent."
  spec.homepage = "https://github.com/qasase/qasa-codeagent"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb", "bin/*", "templates/**/*"]
  spec.bindir = "bin"
  spec.executables = ["qasa-codeagent"]

  spec.add_dependency "thor", "~> 1.0"
end
