# frozen_string_literal: true

require "thor"

module QasaOpencode
  class CLI < Thor
    default_task :launch

    desc "launch", "Launch OpenCode in read-only mode (default command)"
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

      check("opencode installed") { system("which opencode > /dev/null 2>&1") }
      check("git installed") { system("which git > /dev/null 2>&1") }
      check("workspace exists") { Dir.exist?(QasaOpencode::WORKSPACE_DIR) }
      check("config exists") { File.exist?(QasaOpencode::CONFIG_PATH) }

      QasaOpencode.repos.each do |name, _repo|
        path = File.join(QasaOpencode::WORKSPACE_DIR, name.to_s)
        check("repo #{name} cloned") { Dir.exist?(path) }
      end

      skills_dir = File.join(QasaOpencode::WORKSPACE_DIR, ".opencode", "skills")
      check("skills installed") { Dir.exist?(skills_dir) && !Dir.glob("#{skills_dir}/*.md").empty? }

      config = Config.new
      check("setup marked complete") { config.setup_complete? }

      puts "\nDiagnostics complete."
    end

    desc "reset", "Delete workspace and config to start fresh"
    def reset
      print "This will delete #{QasaOpencode::WORKSPACE_DIR} and #{QasaOpencode::CONFIG_PATH}. Continue? [y/N] "
      answer = $stdin.gets&.strip&.downcase
      unless answer == "y"
        puts "Aborted."
        return
      end

      if Dir.exist?(QasaOpencode::WORKSPACE_DIR)
        FileUtils.rm_rf(QasaOpencode::WORKSPACE_DIR)
        puts "Deleted #{QasaOpencode::WORKSPACE_DIR}"
      end

      if File.exist?(QasaOpencode::CONFIG_PATH)
        File.delete(QasaOpencode::CONFIG_PATH)
        puts "Deleted #{QasaOpencode::CONFIG_PATH}"
      end

      puts "Reset complete. Run `qasa-opencode` to set up again."
    end

    desc "version", "Print the version"
    def version
      puts "qasa-opencode #{QasaOpencode::VERSION}"
    end

    private

    def first_run(config)
      puts "Welcome to qasa-opencode! Starting first-time setup...\n\n"

      installer = Installer.new
      installer.ensure_opencode!

      workspace = Workspace.new
      workspace.setup!

      installer.clone_repos!

      skills = Skills.new
      skills.install!

      config.mark_setup_complete!
      config.touch_last_run!

      puts "\nSetup complete! Launching OpenCode..."
      Launcher.new.launch!
    end

    def subsequent_run(config)
      puts "Updating repos..."
      launcher = Launcher.new
      launcher.pull_repos!

      Skills.new.install!

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
