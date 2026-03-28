# frozen_string_literal: true

module QasaCodeagent
  module Agents
    REGISTRY = {
      "claude_code" => ClaudeCode,
      "opencode" => OpenCode,
      "custom" => Custom
    }.freeze

    def self.for(key, custom_command: nil)
      klass = REGISTRY.fetch(key) do
        abort "Error: Unknown agent '#{key}'. Valid agents: #{REGISTRY.keys.join(", ")}"
      end

      if key == "custom"
        klass.new(custom_command)
      else
        klass.new
      end
    end
  end
end
