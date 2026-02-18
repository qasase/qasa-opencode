# frozen_string_literal: true

require "yaml"
require "open3"
require "fileutils"

module QasaOpencode
  VERSION = "0.1.0"
  ORG = ENV.fetch("QASA_ORG", "qasa")
  WORKSPACE_DIR = File.expand_path("~/qasa-workspace")
  CONFIG_PATH = File.expand_path("~/.qasa-opencode.yml")

  DEFAULT_REPOS = {
    "frontend" => "#{ORG}/frontend",
    "backend" => "#{ORG}/backend"
  }.freeze

  def self.repos
    if ENV["QASA_REPOS"]
      # Format: "name:org/repo,name:org/repo"
      ENV["QASA_REPOS"].split(",").each_with_object({}) do |entry, hash|
        name, repo = entry.strip.split(":", 2)
        hash[name] = repo
      end
    else
      DEFAULT_REPOS
    end
  end

  GEM_ROOT = File.expand_path("..", __dir__)
end

require_relative "config"
require_relative "installer"
require_relative "workspace"
require_relative "skills"
require_relative "launcher"
require_relative "cli"
