# frozen_string_literal: true

require "yaml"
require "open3"
require "fileutils"

module QasaOpencode
  VERSION = "0.1.0"
  WORKSPACE_DIR = File.expand_path("~/qasa-workspace")
  CONFIG_PATH = File.expand_path("~/.qasa-opencode.yml")

  def self.repos
    config = Config.new
    config["repos"] || {}
  end

  GEM_ROOT = File.expand_path("..", __dir__)
end

require_relative "config"
require_relative "installer"
require_relative "workspace"
require_relative "skills"
require_relative "launcher"
require_relative "cli"
