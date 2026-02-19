# frozen_string_literal: true

require "spec_helper"
require "securerandom"
require "active_support/all"

# Mocking parts of Rails and the engine for the test
module ActionView
  module Helpers
    module FormHelper; end
    module FormTagHelper; end
  end
end

# Load the helper
require_relative "../../../app/helpers/redsys_ruby/payments_helper"

module RedsysRuby
  class Configuration
    def self.load; end
  end
  module Engine
    def self.routes; end
  end
end

RSpec.describe RedsysRuby::PaymentsHelper do
  let(:helper_class) do
    Class.new do
      include RedsysRuby::PaymentsHelper

      def request
        Struct.new(:base_url).new("http://test.host")
      end

      def form_with(options, &block)
        f = Object.new
        def f.hidden_field(*args); ""; end
        def f.submit(*args); ""; end
        yield f
      end

      def concat(text)
        text
      end
    end
  end

  let(:helper) { helper_class.new }
  let(:config) do
    double(
      "Configuration",
      merchant_key: Base64.strict_encode64("a" * 32),
      merchant_code: "123456789",
      terminal: "001",
      environment: "test"
    )
  end

  before do
    allow(RedsysRuby::Configuration).to receive(:load).and_return(config)

    url_helpers = double("UrlHelpers")
    allow(url_helpers).to receive(:ok_payments_url).and_return("http://test.host/ok")
    allow(url_helpers).to receive(:ko_payments_url).and_return("http://test.host/ko")

    routes = double("Routes", url_helpers: url_helpers)
    allow(RedsysRuby::Engine).to receive(:routes).and_return(routes)
  end

  describe "#redsys_payment_form" do
    it "generates a 12-digit order ID when none is provided" do
      # We capture the params passed to TPV.payment_data to verify the order ID
      tpv = instance_double(RedsysRuby::TPV)
      allow(RedsysRuby::TPV).to receive(:new).and_return(tpv)

      captured_params = nil
      allow(tpv).to receive(:payment_data) do |params|
        captured_params = params
        { Ds_SignatureVersion: "HMAC_SHA256_V1", Ds_MerchantParameters: "params", Ds_Signature: "sig" }
      end

      helper.redsys_payment_form(amount: 10.5)

      expect(captured_params[:Ds_Merchant_Order]).to match(/\A\d{12}\z/)
    end

    it "uses SecureRandom to generate the order ID" do
      expect(SecureRandom).to receive(:random_number).with(10**12).and_return(123456789012)

      tpv = instance_double(RedsysRuby::TPV)
      allow(RedsysRuby::TPV).to receive(:new).and_return(tpv)
      allow(tpv).to receive(:payment_data).and_return({ Ds_SignatureVersion: "HMAC_SHA256_V1", Ds_MerchantParameters: "params", Ds_Signature: "sig" })

      helper.redsys_payment_form(amount: 10.5)
    end

    it "uses the provided order ID" do
      tpv = instance_double(RedsysRuby::TPV)
      allow(RedsysRuby::TPV).to receive(:new).and_return(tpv)

      captured_params = nil
      allow(tpv).to receive(:payment_data) do |params|
        captured_params = params
        { Ds_SignatureVersion: "HMAC_SHA256_V1", Ds_MerchantParameters: "params", Ds_Signature: "sig" }
      end

      helper.redsys_payment_form(amount: 10.5, order: "MYORDER123")

      expect(captured_params[:Ds_Merchant_Order]).to eq("MYORDER123")
    end
  end
end
