# frozen_string_literal: true

module RedsysRuby
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :merchant_key, :merchant_code, :terminal, :environment

    validates :merchant_key, :merchant_code, :terminal, :environment, presence: true

    CONFIG_PATH = Rails.root.join("config", "redsys.yml")

    def self.load
      if File.exist?(CONFIG_PATH)
        config = YAML.load_file(CONFIG_PATH)[Rails.env] || {}
        new(config)
      else
        new(environment: "test", terminal: "001")
      end
    end

    def save
      return false unless valid?

      config_data = {}
      if File.exist?(CONFIG_PATH)
        config_data = YAML.load_file(CONFIG_PATH) || {}
      end

      config_data[Rails.env] = attributes
      File.write(CONFIG_PATH, config_data.to_yaml)
      true
    end

    def attributes
      {
        "merchant_key" => merchant_key,
        "merchant_code" => merchant_code,
        "terminal" => terminal,
        "environment" => environment
      }
    end
  end
end
