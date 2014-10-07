module Lobsters
  module Config

    mattr_accessor :settings
    mattr_accessor :saved_settings

    def self.load!
      begin
        config = YAML.load_file("#{Rails.root}/config/application.yml")[Rails.env] || {}
      rescue StandardError, Errno::ENOENT
        config = {}
      ensure
        self.settings = config.with_indifferent_access
      end
    end

    def self.[](key)
      load! if !settings
      value = if settings[key.to_s]
        settings[key.to_s]
      elsif ENV[key.to_s.upcase]
        ENV[key.to_s.upcase]
      else
        nil
      end

      if value == 'true'
        true
      elsif value == 'false'
        false
      else
        value
      end
    end

    def self.[]=(key, value)
      settings[key.to_s] = value
    end

    def self.get(key, default = nil)
      self[key].present? ? self[key] : (default || self[key])
    end

    def self.save_settings!
      self.saved_settings = Marshal.load(Marshal.dump(settings))
    end

    def self.restore_settings!
      self.settings = saved_settings || settings
    end

    def self.inspect
      "#<Lobsters::Config settings: #{settings.inspect}, saved_settings: #{saved_settings.inspect}>"
    end

  end
end
