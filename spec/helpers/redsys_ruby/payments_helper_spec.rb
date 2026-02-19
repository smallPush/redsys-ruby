# frozen_string_literal: true

require "spec_helper"
require "redsys-ruby"
require_relative "../../../app/helpers/redsys_ruby/payments_helper"
require "action_view"
require "active_support/all"

# Mock RedsysRuby::Configuration since we can't easily load it without activemodel
module Rails
  class Engine
  end
end

module RedsysRuby
  class Configuration
    def self.load; end
  end

  # Mock RedsysRuby::Engine
  class Engine < Rails::Engine
  end
end

RSpec.describe RedsysRuby::PaymentsHelper, type: :helper do
  # A simple mock for the helper's dependencies
  let(:helper) do
    Class.new do
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::UrlHelper
      include RedsysRuby::PaymentsHelper

      attr_reader :request

      def initialize(request)
        @request = request
      end

      # Mock form_with to just yield a builder-like object
      def form_with(url:, method:, local:, html:, &block)
        block.call(Object.new.tap { |o|
          def o.method_missing(*args); self; end
          def o.respond_to_missing?(*args); true; end
        })
      end

      def concat(text)
        # do nothing
      end
    end.new(request)
  end

  let(:config) do
    double(
      "Configuration",
      merchant_key: "abc",
      merchant_code: "123456789",
      terminal: "001",
      environment: "test"
    )
  end

  let(:tpv) { instance_double(RedsysRuby::TPV) }
  let(:request) { double("request", base_url: "http://example.com") }

  before do
    allow(RedsysRuby::Configuration).to receive(:load).and_return(config)
    allow(RedsysRuby::TPV).to receive(:new).and_return(tpv)
    allow(tpv).to receive(:payment_data).and_return({
      Ds_SignatureVersion: "v1",
      Ds_MerchantParameters: "params",
      Ds_Signature: "sig"
    })

    # Mock Rails engine routes
    routes_mock = double("routes")
    url_helpers_mock = double("url_helpers")
    allow(RedsysRuby::Engine).to receive(:routes).and_return(routes_mock)
    allow(routes_mock).to receive(:url_helpers).and_return(url_helpers_mock)
    allow(url_helpers_mock).to receive(:ok_payments_url).and_return("http://ok.com")
    allow(url_helpers_mock).to receive(:ko_payments_url).and_return("http://ko.com")
  end

  describe "#redsys_payment_form" do
    it "correctly converts amount 0.29 to '29'" do
      expect(tpv).to receive(:payment_data).with(hash_including(Ds_Merchant_Amount: "29"))
      helper.redsys_payment_form(amount: 0.29)
    end

    it "correctly converts amount 0.58 to '58'" do
      expect(tpv).to receive(:payment_data).with(hash_including(Ds_Merchant_Amount: "58"))
      helper.redsys_payment_form(amount: 0.58)
    end

    it "correctly converts string amount '0.29' to '29'" do
      expect(tpv).to receive(:payment_data).with(hash_including(Ds_Merchant_Amount: "29"))
      helper.redsys_payment_form(amount: "0.29")
    end

    it "correctly converts BigDecimal amount 0.29 to '29'" do
      expect(tpv).to receive(:payment_data).with(hash_including(Ds_Merchant_Amount: "29"))
      helper.redsys_payment_form(amount: BigDecimal("0.29"))
    end
  end
end
