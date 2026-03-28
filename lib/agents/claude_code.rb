# frozen_string_literal: true

module QasaCodeagent
  module Agents
    class ClaudeCode < Base
      def name
        "Claude Code"
      end

      def binary_name
        "claude"
      end

      def install_templates!(workspace_dir, gem_root)
        src = File.join(gem_root, "templates", "claude_code", "CLAUDE.md")
        dest = File.join(workspace_dir, "CLAUDE.md")
        FileUtils.cp(src, dest)
        puts "Installed CLAUDE.md with read-only instructions"
      end

      def launch_command
        ["claude"]
      end

      def template_check_path(workspace_dir)
        File.join(workspace_dir, "CLAUDE.md")
      end

      private

      def install_instructions
        "Install Claude Code: https://docs.anthropic.com/en/docs/claude-code/overview"
      end
    end
  end
end
