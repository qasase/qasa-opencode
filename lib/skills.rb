# frozen_string_literal: true

module QasaOpencode
  class Skills
    TEMPLATES_DIR = File.join(QasaOpencode::GEM_ROOT, "templates", "skills")

    def install!
      target_dir = File.join(QasaOpencode::WORKSPACE_DIR, ".opencode", "skills")
      FileUtils.mkdir_p(target_dir)

      Dir.glob(File.join(TEMPLATES_DIR, "*.md")).each do |template|
        dest = File.join(target_dir, File.basename(template))
        FileUtils.cp(template, dest)
        puts "Installed skill: #{File.basename(template)}"
      end
    end
  end
end
