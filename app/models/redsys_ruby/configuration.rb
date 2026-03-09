# frozen_string_literal: true

module RedsysRuby
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :merchant_key, :merchant_code, :terminal, :environment, :merchant_url

    validates :merchant_key, :merchant_code, :terminal, :environment, presence: true
    validates :merchant_code, format: { with: /\A\d{9}\z/, message: "debe tener exactamente 9 dígitos" }
    validates :terminal, format: { with: /\A\d{3}\z/, message: "debe tener exactamente 3 dígitos" }
    validates :environment, inclusion: { in: %w[test production], message: "debe ser 'test' o 'production'" }

    CONFIG_PATH = Rails.root.join("config", "redsys.yml")

    def self.load
      config = load_config_file[Rails.env] || {}
      creds = safe_credentials

      env = ENV["REDSYS_ENVIRONMENT"] || creds[:environment] || config["environment"] || "test"

      key = ENV["REDSYS_MERCHANT_KEY"] || creds[:merchant_key] || config["merchant_key"]
      code = ENV["REDSYS_MERCHANT_CODE"] || creds[:merchant_code] || config["merchant_code"]
      term = ENV["REDSYS_TERMINAL"] || creds[:terminal] || config["terminal"]
      m_url = ENV["REDSYS_MERCHANT_URL"] || creds[:merchant_url] || config["merchant_url"]

      new(
        merchant_key: key,
        merchant_code: code,
        terminal: term,
        environment: env,
        merchant_url: m_url
      )
    end

    def merchant_key_from_secure_source?
      ENV["REDSYS_MERCHANT_KEY"].present? ||
        self.class.send(:safe_credentials)&.dig(:merchant_key).present?
    end

    def save
      return false unless valid?

      config_data = self.class.send(:load_config_file)

      # We exclude merchant_key from the YAML file for security reasons.
      # Secrets should be managed via environment variables or encrypted credentials.
      data_to_save = attributes.except("merchant_key")

      config_data[Rails.env] = data_to_save
      File.write(CONFIG_PATH, config_data.to_yaml)
      self.class.clear_config_cache
      true
    end

    def attributes
      {
        "merchant_key" => merchant_key,
        "merchant_code" => merchant_code,
        "terminal" => terminal,
        "environment" => environment,
        "merchant_url" => merchant_url
      }
    end

    def self.load_config_file
      return Marshal.load(Marshal.dump(@config_data)) if defined?(@config_data) && !@config_data.nil?

      @config_data = if File.exist?(CONFIG_PATH)
                       YAML.safe_load_file(CONFIG_PATH, aliases: true) || {}
                     else
                       {}
                     end
      Marshal.load(Marshal.dump(@config_data))
    end

    def self.clear_config_cache
      @config_data = nil
    end

    def self.safe_credentials
      Rails.application.credentials.redsys || {}
    rescue StandardError
      {}
    end

    private_class_method :load_config_file, :safe_credentials
  end
end
