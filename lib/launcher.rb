# frozen_string_literal: true

module QasaOpencode
  class Launcher
    def launch!
      Dir.chdir(QasaOpencode::WORKSPACE_DIR) do
        puts "Launching OpenCode in read-only mode..."
        exec("opencode", "--agent", "logic-explorer")
      end
    end

    def pull_repos!
      QasaOpencode.repos.each do |name, _repo|
        path = File.join(QasaOpencode::WORKSPACE_DIR, name.to_s)
        unless Dir.exist?(path)
          puts "Warning: #{name} repo not found at #{path}, skipping pull."
          next
        end

        puts "Pulling latest for #{name}..."
        output, status = Open3.capture2e("git", "-C", path, "pull", "--ff-only")
        if status.success?
          puts "Updated #{name}."
        else
          puts "Warning: Could not fast-forward #{name}. You may need to resolve this manually.\n#{output}"
        end
      end
    end
  end
end
