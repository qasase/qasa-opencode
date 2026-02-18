# frozen_string_literal: true

module QasaOpencode
  class Workspace
    CONTEXT_TEMPLATE = <<~MARKDOWN
      # Workspace

      This workspace contains the project repositories.
      It is configured for **read-only** analysis via OpenCode.

      ## Rules

      - All queries are read-only. No code modifications are permitted.
      - Use the provided skills for SQL analysis, business logic review, and code exploration.
      - When querying databases, use SELECT statements only.
    MARKDOWN

    def setup!
      create_directories!
      write_context!
    end

    private

    def create_directories!
      [
        QasaOpencode::WORKSPACE_DIR,
        File.join(QasaOpencode::WORKSPACE_DIR, ".opencode"),
        File.join(QasaOpencode::WORKSPACE_DIR, ".opencode", "skills"),
        File.join(QasaOpencode::WORKSPACE_DIR, ".qasa")
      ].each do |dir|
        FileUtils.mkdir_p(dir)
        puts "Created #{dir}"
      end
    end

    def write_context!
      path = File.join(QasaOpencode::WORKSPACE_DIR, "context.md")
      File.write(path, CONTEXT_TEMPLATE)
      puts "Wrote context file to #{path}"
    end
  end
end
