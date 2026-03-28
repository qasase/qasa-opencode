# frozen_string_literal: true

module QasaCodeagent
  class SshHelper
    SSH_DIR = File.expand_path("~/.ssh")
    KEY_TYPES = %w[id_ed25519 id_rsa].freeze

    def self.key_exists?
      KEY_TYPES.any? { |k| File.exist?(File.join(SSH_DIR, k)) }
    end

    def self.public_key_path
      KEY_TYPES.each do |k|
        path = File.join(SSH_DIR, "#{k}.pub")
        return path if File.exist?(path)
      end
      nil
    end

    def self.can_connect?(host = "github.com")
      _output, status = Open3.capture2e("ssh", "-T", "-o", "StrictHostKeyChecking=accept-new", "-o", "ConnectTimeout=5", "git@#{host}")
      # ssh -T git@github.com exits with 1 on success (it prints "Hi username!")
      # and 255 on auth failure
      status.exitstatus != 255
    end

    def self.host_from_url(url)
      if url.start_with?("git@")
        url.split("@").last.split(":").first
      elsif url.include?("://")
        URI.parse(url).host
      end
    rescue StandardError
      nil
    end

    def self.ssh_url?(url)
      url.start_with?("git@")
    end

    def self.ensure_access!(repo_url)
      return unless ssh_url?(repo_url)

      host = host_from_url(repo_url) || "github.com"

      unless key_exists?
        generate_key!(host)
      end

      unless can_connect?(host)
        show_key_instructions(host)
      end
    end

    def self.generate_key!(host = "github.com")
      puts "\n" + ("=" * 60)
      puts "  SSH Key Setup"
      puts "=" * 60
      puts "\nNo SSH key found. Let's create one so you can access the code repositories.\n\n"

      FileUtils.mkdir_p(SSH_DIR, mode: 0o700)

      key_path = File.join(SSH_DIR, "id_ed25519")

      print "Enter your email address (for the SSH key label): "
      email = $stdin.gets&.strip
      email = "qasa-user@#{host}" if email.nil? || email.empty?

      puts "\nStep 1 of 3: Generating a new SSH key..."
      output, status = Open3.capture2e("ssh-keygen", "-t", "ed25519", "-C", email, "-f", key_path, "-N", "")
      unless status.success?
        puts "Warning: Could not generate SSH key automatically.\n#{output}"
        puts "You can generate one manually by running:"
        puts "  ssh-keygen -t ed25519 -C \"#{email}\""
        return false
      end
      puts "SSH key created at #{key_path}\n\n"

      show_key_instructions(host)
    end

    def self.show_key_instructions(host = "github.com")
      pub_path = public_key_path
      unless pub_path
        puts "No public key found. Ask a developer on your team for help setting up SSH access."
        return false
      end

      pub_key = File.read(pub_path).strip

      puts "Step 2 of 3: Your public key:\n\n"
      puts "  #{pub_key}\n\n"

      copy_to_clipboard(pub_key)

      settings_url = if host.include?("github.com")
                       "https://github.com/settings/ssh/new"
                     else
                       "https://#{host} (find SSH key settings in your account)"
                     end

      puts "Step 3 of 3: Add this key to #{host}"
      puts "  1. Open this link: #{settings_url}"
      puts "  2. Paste the key above and click \"Add SSH key\""
      puts ""
      puts "  NOTE: If your organization requires it, you may need a developer"
      puts "  on your team to add your key to the GitHub organization."
      puts ""

      print "Press Enter when you've added the key (or 'skip' to continue anyway): "
      answer = $stdin.gets&.strip&.downcase

      if answer == "skip"
        puts "Skipping SSH verification. Cloning may fail if the key isn't set up."
        return false
      end

      if can_connect?(host)
        puts "SSH connection to #{host} successful!\n\n"
        true
      else
        puts "Could not connect to #{host} via SSH."
        puts "This might mean:"
        puts "  - The key hasn't been added yet"
        puts "  - Your organization requires a developer to approve the key"
        puts "  - There's a network issue"
        puts ""
        puts "Ask your team lead for help if you're stuck."
        false
      end
    end

    def self.copy_to_clipboard(text)
      if system("which pbcopy > /dev/null 2>&1")
        IO.popen("pbcopy", "w") { |io| io.write(text) }
        puts "(Copied to clipboard)\n\n"
      elsif system("which xclip > /dev/null 2>&1")
        IO.popen("xclip -selection clipboard", "w") { |io| io.write(text) }
        puts "(Copied to clipboard)\n\n"
      elsif system("which xsel > /dev/null 2>&1")
        IO.popen("xsel --clipboard --input", "w") { |io| io.write(text) }
        puts "(Copied to clipboard)\n\n"
      else
        puts "(Copy the key above manually)\n\n"
      end
    rescue StandardError
      puts "(Copy the key above manually)\n\n"
    end
  end
end
