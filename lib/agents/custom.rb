# frozen_string_literal: true

module QasaCodeagent
  module Agents
    class Custom < Base
      attr_reader :command_string

      def initialize(command_string = nil)
        super()
        @command_string = command_string
      end

      def name
        "Custom (#{command_string || "not configured"})"
      end

      def binary_name
        return nil unless command_string

        command_string.split.first
      end

      def check_installed!
        unless command_string
          abort "Error: No custom command configured. Run `qasa-codeagent reset` and set up again."
        end

        bin = binary_name
        output, status = Open3.capture2e("which #{bin}")
        unless status.success?
          abort "Error: #{bin} is not installed. Make sure the command '#{command_string}' is available in your PATH."
        end
        puts "Found #{bin} at #{output.strip}"
      end

      def install_templates!(workspace_dir, gem_root)
        # Copy shared context only — no agent-specific templates for custom agents
        src = File.join(gem_root, "templates", "shared", "context.md")
        dest = File.join(workspace_dir, "context.md")
        FileUtils.cp(src, dest) if File.exist?(src)
        puts "Installed shared context for custom agent"
      end

      def launch_command
        command_string.split
      end

      def template_check_path(workspace_dir)
        File.join(workspace_dir, "context.md")
      end
    end
  end
end
