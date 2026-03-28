# frozen_string_literal: true

module QasaCodeagent
  class Installer
    def ensure_agent!(agent)
      agent.check_installed!
    end

    def clone_repos!(repos)
      repos.each do |name, url|
        target = File.join(QasaCodeagent::WORKSPACE_DIR, name.to_s)
        if Dir.exist?(target)
          puts "Repo #{name} already cloned at #{target}, skipping."
          next
        end

        puts "Cloning #{name} into #{target}..."
        output, status = Open3.capture2e("git", "clone", url, target)
        unless status.success?
          if SshHelper.ssh_url?(url) && output.include?("Permission denied")
            puts "Clone failed due to SSH authentication.\n\n"
            SshHelper.ensure_access!(url)

            # Retry once after SSH setup
            puts "\nRetrying clone for #{name}..."
            output, status = Open3.capture2e("git", "clone", url, target)
            unless status.success?
              abort "Error: Failed to clone #{name} after SSH setup.\n#{output}\n\nAsk a developer on your team for help."
            end
            puts "Cloned #{name} successfully."
            next
          end

          abort "Error: Failed to clone #{name}.\n#{output}"
        end
        puts "Cloned #{name} successfully."
      end
    end
  end
end
