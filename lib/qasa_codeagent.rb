# frozen_string_literal: true

require "yaml"
require "open3"
require "fileutils"
require "uri"

module QasaCodeagent
  VERSION = "1.0.0"
  WORKSPACE_DIR = File.expand_path("~/qasa-workspace")
  CONFIG_PATH = File.expand_path("~/.qasa-codeagent.yml")
  LEGACY_CONFIG_PATH = File.expand_path("~/.qasa-opencode.yml")

  def self.repos
    config = Config.new
    config["repos"] || {}
  end

  GEM_ROOT = File.expand_path("..", __dir__)
end

require_relative "agents/base"
require_relative "agents/claude_code"
require_relative "agents/opencode"
require_relative "agents/custom"
require_relative "agents/registry"
require_relative "config"
require_relative "ssh_helper"
require_relative "installer"
require_relative "workspace"
require_relative "launcher"
require_relative "cli"
