# frozen_string_literal: true

require "thor"

module QasaCodeagent
  class CLI < Thor
    default_task :launch

    desc "launch", "Launch your AI coding agent in read-only mode (default command)"
    def launch
      config = Config.new

      if config.setup_complete?
        subsequent_run(config)
      else
        first_run(config)
      end
    end

    desc "doctor", "Check that all dependencies and configuration are healthy"
    def doctor
      puts "Running diagnostics...\n\n"

      config = Config.new
      agent = config.agent

      check("#{agent.binary_name || "agent"} installed") do
        agent.binary_name && system("which #{agent.binary_name} > /dev/null 2>&1")
      end
      check("git installed") { system("which git > /dev/null 2>&1") }
      check("SSH key exists") { SshHelper.key_exists? }
      check("workspace exists") { Dir.exist?(QasaCodeagent::WORKSPACE_DIR) }
      check("config exists") { File.exist?(QasaCodeagent::CONFIG_PATH) }

      QasaCodeagent.repos.each do |name, url|
        path = File.join(QasaCodeagent::WORKSPACE_DIR, name.to_s)
        check("repo #{name} cloned") { Dir.exist?(path) }

        if SshHelper.ssh_url?(url)
          host = SshHelper.host_from_url(url)
          check("SSH access to #{host}") { SshHelper.can_connect?(host) } if host
        end
      end

      if config.setup_complete?
        template_path = agent.template_check_path(QasaCodeagent::WORKSPACE_DIR)
        check("agent template installed") { File.exist?(template_path) }
      end

      check("setup marked complete") { config.setup_complete? }

      puts "\nAgent: #{agent.name}"
      puts "Diagnostics complete."
    end

    desc "reset", "Delete workspace and config to start fresh"
    def reset
      print "This will delete #{QasaCodeagent::WORKSPACE_DIR} and #{QasaCodeagent::CONFIG_PATH}. Continue? [y/N] "
      answer = $stdin.gets&.strip&.downcase
      unless answer == "y"
        puts "Aborted."
        return
      end

      if Dir.exist?(QasaCodeagent::WORKSPACE_DIR)
        FileUtils.rm_rf(QasaCodeagent::WORKSPACE_DIR)
        puts "Deleted #{QasaCodeagent::WORKSPACE_DIR}"
      end

      if File.exist?(QasaCodeagent::CONFIG_PATH)
        File.delete(QasaCodeagent::CONFIG_PATH)
        puts "Deleted #{QasaCodeagent::CONFIG_PATH}"
      end

      puts "Reset complete. Run `qasa-codeagent` to set up again."
    end

    desc "version", "Print the version"
    def version
      puts "qasa-codeagent #{QasaCodeagent::VERSION}"
    end

    private

    def first_run(config)
      puts "Welcome to qasa-codeagent! Starting first-time setup...\n\n"
      puts "This tool helps you explore your company's code repositories using an AI agent."
      puts "You'll need SSH access to your company's repositories."
      puts "The tool will help you set this up if needed.\n\n"

      agent_key, custom_command = prompt_for_agent
      config["agent"] = agent_key
      config["custom_command"] = custom_command
      config.save

      agent = config.agent
      installer = Installer.new
      installer.ensure_agent!(agent)

      repos = prompt_for_repos
      config["repos"] = repos
      config.save

      workspace = Workspace.new(agent)
      workspace.setup!

      installer.clone_repos!(repos)

      config.mark_setup_complete!
      config.touch_last_run!

      puts "\nSetup complete! Launching #{agent.name}..."
      Launcher.new(agent).launch!
    end

    def prompt_for_agent
      puts "Which AI coding agent would you like to use?\n\n"
      puts "  1. Claude Code (recommended — requires Claude team plan)"
      puts "  2. OpenCode"
      puts "  3. Other (specify a custom command)\n\n"

      print "Enter choice [1]: "
      choice = $stdin.gets&.strip
      choice = "1" if choice.nil? || choice.empty?

      case choice
      when "1"
        ["claude_code", nil]
      when "2"
        ["opencode", nil]
      when "3"
        print "Enter the command to launch your agent (e.g. 'cursor', 'aider'): "
        cmd = $stdin.gets&.strip
        if cmd.nil? || cmd.empty?
          abort "Error: A command is required for custom agents."
        end
        ["custom", cmd]
      else
        puts "Invalid choice, defaulting to Claude Code."
        ["claude_code", nil]
      end
    end

    def prompt_for_repos
      puts "\nWhich repositories should be available in the workspace?"
      puts "You'll need the Git URL for each repo (e.g. git@github.com:org/repo.git)."
      puts "Your team lead can provide these if you're unsure.\n\n"

      repos = {}
      loop do
        print "Repository Git URL (or press Enter to finish): "
        url = $stdin.gets&.strip
        break if url.nil? || url.empty?

        # Derive a friendly name from the URL
        default_name = File.basename(url, ".git").gsub(/[^a-zA-Z0-9_-]/, "")
        print "Local folder name [#{default_name}]: "
        name = $stdin.gets&.strip
        name = default_name if name.nil? || name.empty?

        repos[name] = url
        puts "  Added #{name} -> #{url}\n\n"
      end

      if repos.empty?
        abort "Error: At least one repository is required. Run qasa-codeagent again to retry."
      end

      puts ""
      repos
    end

    def subsequent_run(config)
      agent = config.agent

      puts "Updating repos..."
      launcher = Launcher.new(agent)
      launcher.pull_repos!

      # Re-install agent template in case it was updated
      Workspace.new(agent).install_agent!

      config.touch_last_run!

      launcher.launch!
    end

    def check(label)
      result = yield rescue false
      status = result ? "OK" : "FAIL"
      puts "  [#{status}] #{label}"
    end
  end
end
