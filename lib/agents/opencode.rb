# frozen_string_literal: true

module QasaCodeagent
  module Agents
    class OpenCode < Base
      def name
        "OpenCode"
      end

      def binary_name
        "opencode"
      end

      def install_templates!(workspace_dir, gem_root)
        src = File.join(gem_root, "templates", "opencode", "agent", "logic-explorer.md")
        dest_dir = File.join(workspace_dir, "agent")
        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp(src, File.join(dest_dir, "logic-explorer.md"))
        puts "Installed read-only agent: logic-explorer"
      end

      def launch_command
        ["opencode", "--agent", "logic-explorer"]
      end

      def template_check_path(workspace_dir)
        File.join(workspace_dir, "agent", "logic-explorer.md")
      end

      private

      def install_instructions
        "Install OpenCode: https://opencode.ai"
      end
    end
  end
end
