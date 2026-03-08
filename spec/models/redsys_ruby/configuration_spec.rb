# frozen_string_literal: true

require "spec_helper"
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
