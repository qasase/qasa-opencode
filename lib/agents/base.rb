# frozen_string_literal: true

module QasaCodeagent
  module Agents
    class Base
      def name
        raise NotImplementedError
      end

      def binary_name
        raise NotImplementedError
      end

      def check_installed!
        output, status = Open3.capture2e("which #{binary_name}")
        unless status.success?
          abort "Error: #{binary_name} is not installed.\n#{install_instructions}"
        end
        puts "Found #{binary_name} at #{output.strip}"
      end

      def install_templates!(workspace_dir, gem_root)
        raise NotImplementedError
      end

      def launch_command
        raise NotImplementedError
      end

      def template_check_path(_workspace_dir)
        raise NotImplementedError
      end

      private

      def install_instructions
        "Please install #{name} before continuing."
      end
    end
  end
end
