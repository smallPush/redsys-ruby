# frozen_string_literal: true

require "spec_helper"
require "active_model"

# Mock Rails constant specifically for the file load
module Rails
  def self.root
    require "pathname"
    Pathname.new("/mocked/rails/root")
  end
end

require_relative "../../../app/models/redsys_ruby/configuration"

RSpec.describe RedsysRuby::Configuration, type: :model do
  describe ".load" do
    let(:config) { described_class.load }
    let(:mock_credentials) { double("credentials") }

    before do
      # Clear any existing relevant ENV variables to ensure a clean state
      @original_env = {
        "REDSYS_ENVIRONMENT" => ENV["REDSYS_ENVIRONMENT"],
        "REDSYS_MERCHANT_KEY" => ENV["REDSYS_MERCHANT_KEY"],
        "REDSYS_MERCHANT_CODE" => ENV["REDSYS_MERCHANT_CODE"],
        "REDSYS_TERMINAL" => ENV["REDSYS_TERMINAL"]
      }

      ENV["REDSYS_ENVIRONMENT"] = nil
      ENV["REDSYS_MERCHANT_KEY"] = nil
      ENV["REDSYS_MERCHANT_CODE"] = nil
      ENV["REDSYS_TERMINAL"] = nil

      # Mock Rails to control the environment and credentials
      allow(Rails).to receive(:env).and_return("test")

      # Mock the Rails.application.credentials
      allow(Rails).to receive_message_chain(:application, :credentials).and_return(mock_credentials)
      allow(mock_credentials).to receive(:redsys).and_return(nil)

      # Mock the YAML load to return empty by default
      allow(RedsysRuby::Configuration).to receive(:load_config_file).and_return({})
    end

    after do
      # Restore original ENV variables
      @original_env.each do |key, value|
        ENV[key] = value
      end
    end

    context "when all configuration sources are empty and env is test" do
      it "returns a Configuration object with default test values" do
        expect(config.environment).to eq("test")
        expect(config.merchant_key).to eq("sq7HjmUOBfKmC576ILgskD5srU870gJ7")
        expect(config.merchant_code).to eq("999008881")
        expect(config.terminal).to eq("001")
        expect(config).to be_valid
      end
    end

    context "when configuration sources are empty and env is production" do
      before do
        allow(Rails).to receive(:env).and_return("production")
        ENV["REDSYS_ENVIRONMENT"] = "production"
      end

      it "does not apply default test values" do
        expect(config.environment).to eq("production")
        expect(config.merchant_key).to be_nil
        expect(config.merchant_code).to be_nil
        expect(config.terminal).to be_nil
        expect(config).not_to be_valid
      end
    end

    context "when configuration is provided via YAML" do
      before do
        yaml_config = {
          "test" => {
            "environment" => "test",
            "merchant_key" => "yaml_key",
            "merchant_code" => "111222333",
            "terminal" => "002"
          }
        }
        allow(RedsysRuby::Configuration).to receive(:load_config_file).and_return(yaml_config)
      end

      it "loads values from YAML" do
        expect(config.merchant_key).to eq("yaml_key")
        expect(config.merchant_code).to eq("111222333")
        expect(config.terminal).to eq("002")
      end
    end

    context "when configuration is provided via Rails credentials" do
      before do
        yaml_config = {
          "test" => {
            "environment" => "test",
            "merchant_key" => "yaml_key",
            "merchant_code" => "111222333",
            "terminal" => "002"
          }
        }
        allow(RedsysRuby::Configuration).to receive(:load_config_file).and_return(yaml_config)

        credentials_config = {
          environment: "test",
          merchant_key: "cred_key",
          merchant_code: "444555666",
          terminal: "003"
        }
        allow(mock_credentials).to receive(:redsys).and_return(credentials_config)
      end

      it "prioritizes credentials over YAML" do
        expect(config.merchant_key).to eq("cred_key")
        expect(config.merchant_code).to eq("444555666")
        expect(config.terminal).to eq("003")
      end
    end

    context "when configuration is provided via ENV variables" do
      before do
        yaml_config = {
          "test" => {
            "environment" => "test",
            "merchant_key" => "yaml_key",
            "merchant_code" => "111222333",
            "terminal" => "002"
          }
        }
        allow(RedsysRuby::Configuration).to receive(:load_config_file).and_return(yaml_config)

        credentials_config = {
          environment: "test",
          merchant_key: "cred_key",
          merchant_code: "444555666",
          terminal: "003"
        }
        allow(mock_credentials).to receive(:redsys).and_return(credentials_config)

        ENV["REDSYS_ENVIRONMENT"] = "production"
        ENV["REDSYS_MERCHANT_KEY"] = "env_key"
        ENV["REDSYS_MERCHANT_CODE"] = "777888999"
        ENV["REDSYS_TERMINAL"] = "004"
      end

      it "prioritizes ENV variables over credentials and YAML" do
        expect(config.environment).to eq("production")
        expect(config.merchant_key).to eq("env_key")
        expect(config.merchant_code).to eq("777888999")
        expect(config.terminal).to eq("004")
      end
    end

    context "when Rails.application.credentials raises an error" do
      before do
        allow(Rails).to receive_message_chain(:application, :credentials).and_raise(StandardError, "Credentials not setup")

        yaml_config = {
          "test" => {
            "merchant_key" => "yaml_key",
            "merchant_code" => "111222333",
            "terminal" => "002"
          }
        }
        allow(RedsysRuby::Configuration).to receive(:load_config_file).and_return(yaml_config)
      end

      it "rescues the error and falls back to YAML" do
        expect(config.merchant_key).to eq("yaml_key")
        expect(config.merchant_code).to eq("111222333")
        expect(config.terminal).to eq("002")
require "rails"
require "active_model"
require "active_model/validations"

# In a standard Rails engine setup, Rails.root is defined by the dummy app.
# Since we are running tests isolated from a dummy app, we need to ensure
# Rails.root is stubbed safely without polluting the global module namespace
# permanently for other tests if they don't expect it.
# We use a module prepended to Rails class singleton to provide a safe default.
unless Rails.respond_to?(:root) && Rails.root
  module Rails
    def self.root
      @root ||= Pathname.new(File.expand_path("../../dummy", __dir__))
    end

    def self.env
      @env ||= ActiveSupport::StringInquirer.new("test")
    end
  end
end

# Load the model class manually
require_relative "../../../app/models/redsys_ruby/configuration"

RSpec.describe RedsysRuby::Configuration, type: :model do
  describe "#save" do
    let(:config) do
      described_class.new(
        merchant_key: "sq7HjmUOBfKmC576ILgskD5srU870gJ7",
        merchant_code: "999008881",
        terminal: "001",
        environment: "test"
      }
    end

    it "is valid with valid attributes" do
      config = described_class.new(valid_attributes)
      expect(config).to be_valid
    end

    it "validates presence of merchant_key, merchant_code, terminal, and environment" do
      config = described_class.new(valid_attributes.merge(merchant_key: nil, merchant_code: nil, terminal: nil, environment: nil))
      expect(config).not_to be_valid
      expect(config.errors.messages.keys).to contain_exactly(:merchant_key, :merchant_code, :terminal, :environment)
    end

    it "requires specific formats and lengths for codes" do
      config = described_class.new(valid_attributes.merge(merchant_code: "123", terminal: "12"))
      expect(config).not_to be_valid
      expect(config.errors[:merchant_code]).to include("debe tener exactamente 9 dígitos")
      expect(config.errors[:terminal]).to include("debe tener exactamente 3 dígitos")
    end

    it "requires environment to be test or production" do
      config = described_class.new(valid_attributes.merge(environment: "development"))
      expect(config).not_to be_valid
      expect(config.errors[:environment]).to include("debe ser 'test' o 'production'")
    end
  end

  describe "#attributes" do
    it "returns a hash of the current attributes with string keys" do
      config = described_class.new(merchant_key: "key", merchant_code: "code", terminal: "term", environment: "test")
      expect(config.attributes).to eq({
        "merchant_key" => "key",
        "merchant_code" => "code",
        "terminal" => "term",
        "environment" => "test"
      })
      )
    end

    let(:config_path) { described_class::CONFIG_PATH }

    before do
      # Mock Rails.env for the context of these tests
      allow(Rails).to receive(:env).and_return("test")

      # Mock the private class method load_config_file to return a dummy hash
      allow(described_class).to receive(:load_config_file).and_return({ "production" => { "environment" => "production" } })
    end

    context "when configuration is invalid" do
      it "returns false and does not write to the file" do
        config.merchant_code = "invalid"

        expect(File).not_to receive(:write)
        expect(config.save).to be false
      end
    end

    context "when configuration is valid" do
      it "returns true" do
        allow(File).to receive(:write)
        expect(config.save).to be true
      end

      it "writes the expected YAML to CONFIG_PATH, merging with existing data" do
        expected_data = {
          "production" => { "environment" => "production" },
          "test" => {
            "merchant_code" => "999008881",
            "terminal" => "001",
            "environment" => "test"
          }
        }

        expect(File).to receive(:write).with(config_path, expected_data.to_yaml)
        config.save
      end

      it "excludes merchant_key from the saved file" do
        allow(File).to receive(:write) do |_path, yaml_content|
          saved_hash = YAML.safe_load(yaml_content)
          expect(saved_hash["test"]).not_to have_key("merchant_key")
        end
        config.save
      end
    end
  end
end
