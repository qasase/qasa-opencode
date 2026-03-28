# frozen_string_literal: true

module QasaCodeagent
  class Launcher
    def initialize(agent)
      @agent = agent
    end

    def launch!
      Dir.chdir(QasaCodeagent::WORKSPACE_DIR) do
        puts "Launching #{@agent.name}..."
        system(*@agent.launch_command)
      end

      cleanup_repos!
    end

    def pull_repos!
      QasaCodeagent.repos.each do |name, _repo|
        path = File.join(QasaCodeagent::WORKSPACE_DIR, name.to_s)
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

    private

    def cleanup_repos!
      QasaCodeagent.repos.each do |name, _url|
        path = File.join(QasaCodeagent::WORKSPACE_DIR, name.to_s)
        next unless Dir.exist?(path)

        system("git", "-C", path, "checkout", ".")
        system("git", "-C", path, "clean", "-fd")
      end
      puts "Repos cleaned up for next session."
    end
  end
end
