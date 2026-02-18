# frozen_string_literal: true

module QasaOpencode
  class Config
    DEFAULTS = {
      "setup_complete" => false,
      "workspace_path" => QasaOpencode::WORKSPACE_DIR,
      "last_run" => nil
    }.freeze

    attr_reader :data

    def initialize
      @data = load
    end

    def setup_complete?
      @data["setup_complete"] == true
    end

    def mark_setup_complete!
      @data["setup_complete"] = true
      save
    end

    def touch_last_run!
      @data["last_run"] = Time.now.iso8601
      save
    end

    def workspace_path
      @data["workspace_path"]
    end

    def [](key)
      @data[key.to_s]
    end

    def []=(key, value)
      @data[key.to_s] = value
    end

    def save
      File.write(QasaOpencode::CONFIG_PATH, YAML.dump(@data))
    end

    private

    def load
      if File.exist?(QasaOpencode::CONFIG_PATH)
        DEFAULTS.merge(YAML.safe_load_file(QasaOpencode::CONFIG_PATH) || {})
      else
        DEFAULTS.dup
      end
    end
  end
end
