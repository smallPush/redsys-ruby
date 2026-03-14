# frozen_string_literal: true

require "spec_helper"
require "active_model"
require "ostruct"

# Provide a safe, isolated stub for Rails just for this file,
# ensuring we don't pollute other tests that might require real Rails.
module DummyRails
  def self.root
    Pathname.new(File.expand_path('../../../', __FILE__))
  end

  def self.env
    'test'
  end

  def self.application
    @app ||= OpenStruct.new(credentials: OpenStruct.new(redsys: {}))
  end
end

unless defined?(Rails)
  Rails = DummyRails
end

require_relative "../../../app/models/redsys_ruby/configuration"

RSpec.describe RedsysRuby::Configuration do
  describe "validations" do
    let(:valid_attributes) do
      {
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
    end
  end
end
