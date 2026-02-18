# frozen_string_literal: true

module QasaOpencode
  class Installer
    def ensure_opencode!
      output, status = Open3.capture2e("which opencode")
      unless status.success?
        abort "Error: opencode is not installed. Install it first: https://opencode.ai"
      end
      puts "Found opencode at #{output.strip}"
    end

    def authenticate!
      puts "Authenticating with OpenCode..."
      output, status = Open3.capture2e("opencode auth login")
      unless status.success?
        abort "Error: OpenCode authentication failed.\n#{output}"
      end
      puts "Authentication successful."
    end

    def clone_repos!(repos)
      repos.each do |name, url|
        target = File.join(QasaOpencode::WORKSPACE_DIR, name.to_s)
        if Dir.exist?(target)
          puts "Repo #{name} already cloned at #{target}, skipping."
          next
        end

        puts "Cloning #{name} into #{target}..."
        output, status = Open3.capture2e("git", "clone", url, target)
        unless status.success?
          abort "Error: Failed to clone #{name}.\n#{output}"
        end
        puts "Cloned #{name} successfully."
      end
    end
  end
end
