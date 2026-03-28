# frozen_string_literal: true

module QasaCodeagent
  class Workspace
    def initialize(agent)
      @agent = agent
    end

    def setup!
      create_directories!
      write_context!
      install_agent!
    end

    def install_agent!
      @agent.install_templates!(QasaCodeagent::WORKSPACE_DIR, QasaCodeagent::GEM_ROOT)
    end

    private

    def create_directories!
      [
        QasaCodeagent::WORKSPACE_DIR,
        File.join(QasaCodeagent::WORKSPACE_DIR, ".qasa")
      ].each do |dir|
        FileUtils.mkdir_p(dir)
        puts "Created #{dir}"
      end
    end

    def write_context!
      src = File.join(QasaCodeagent::GEM_ROOT, "templates", "shared", "context.md")
      dest = File.join(QasaCodeagent::WORKSPACE_DIR, "context.md")
      FileUtils.cp(src, dest)
      puts "Wrote context file to #{dest}"
    end
  end
end
