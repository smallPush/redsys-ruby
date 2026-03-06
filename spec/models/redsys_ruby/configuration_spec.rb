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
      end
    end
  end
end
