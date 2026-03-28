# frozen_string_literal: true

module QasaCodeagent
  class Config
    DEFAULTS = {
      "setup_complete" => false,
      "workspace_path" => QasaCodeagent::WORKSPACE_DIR,
      "last_run" => nil,
      "repos" => {},
      "agent" => "claude_code",
      "custom_command" => nil
    }.freeze

    attr_reader :data

    def initialize
      @data = load
    end

    def setup_complete?
      @data["setup_complete"] == true
    end

    def mark_setup_complete!
      @data["setup_complete"] = true
      save
    end

    def touch_last_run!
      @data["last_run"] = Time.now.iso8601
      save
    end

    def workspace_path
      @data["workspace_path"]
    end

    def agent_key
      @data["agent"] || "claude_code"
    end

    def custom_command
      @data["custom_command"]
    end

    def agent
      QasaCodeagent::Agents.for(agent_key, custom_command: custom_command)
    end

    def [](key)
      @data[key.to_s]
    end

    def []=(key, value)
      @data[key.to_s] = value
    end

    def save
      File.write(QasaCodeagent::CONFIG_PATH, YAML.dump(@data))
    end

    private

    def load
      if File.exist?(QasaCodeagent::CONFIG_PATH)
        DEFAULTS.merge(YAML.safe_load_file(QasaCodeagent::CONFIG_PATH) || {})
      elsif File.exist?(QasaCodeagent::LEGACY_CONFIG_PATH)
        migrate_legacy_config
      else
        DEFAULTS.dup
      end
    end

    def migrate_legacy_config
      puts "Found existing qasa-opencode config. Migrating..."
      legacy = YAML.safe_load_file(QasaCodeagent::LEGACY_CONFIG_PATH) || {}
      migrated = DEFAULTS.merge(legacy)
      migrated["agent"] = "opencode" # preserve their existing agent choice
      File.write(QasaCodeagent::CONFIG_PATH, YAML.dump(migrated))
      puts "Config migrated to #{QasaCodeagent::CONFIG_PATH}"
      puts "Your agent is set to OpenCode (your previous setup). You can switch with `qasa-codeagent reset`.\n\n"
      migrated
    end
  end
end
