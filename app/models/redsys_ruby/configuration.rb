# frozen_string_literal: true

module RedsysRuby
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :merchant_key, :merchant_code, :terminal, :environment

    validates :merchant_key, :merchant_code, :terminal, :environment, presence: true
    validates :merchant_code, format: { with: /\A\d{9}\z/, message: "debe tener exactamente 9 dígitos" }
    validates :terminal, format: { with: /\A\d{3}\z/, message: "debe tener exactamente 3 dígitos" }
    validates :environment, inclusion: { in: %w[test production], message: "debe ser 'test' o 'production'" }

    CONFIG_PATH = Rails.root.join("config", "redsys.yml")

    def self.load
      config = {}
      if File.exist?(CONFIG_PATH)
        config = (YAML.safe_load_file(CONFIG_PATH, aliases: true) || {})[Rails.env] || {}
      end

      creds = (Rails.application.credentials.redsys rescue {}) || {}

      env = ENV["REDSYS_ENVIRONMENT"] || creds[:environment] || config["environment"] || "test"

      key = ENV["REDSYS_MERCHANT_KEY"] || creds[:merchant_key] || config["merchant_key"]
      code = ENV["REDSYS_MERCHANT_CODE"] || creds[:merchant_code] || config["merchant_code"]
      term = ENV["REDSYS_TERMINAL"] || creds[:terminal] || config["terminal"]

      if env == "test"
        key ||= "sq7HjmUOBfKmC576ILgskD5srU870gJ7"
        code ||= "999008881"
        term ||= "001"
      end

      new(
        merchant_key: key,
        merchant_code: code,
        terminal: term,
        environment: env
      )
    end

    def merchant_key_from_secure_source?
      ENV["REDSYS_MERCHANT_KEY"].present? || (Rails.application.credentials.redsys&.dig(:merchant_key).present? rescue false)
    end

    def save
      return false unless valid?

      config_data = {}
      if File.exist?(CONFIG_PATH)
        config_data = YAML.safe_load_file(CONFIG_PATH, aliases: true) || {}
      end

      # We exclude merchant_key from the YAML file for security reasons.
      # Secrets should be managed via environment variables or encrypted credentials.
      data_to_save = attributes.except("merchant_key")

      config_data[Rails.env] = data_to_save
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
