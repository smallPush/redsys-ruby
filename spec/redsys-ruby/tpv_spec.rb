# frozen_string_literal: true

require "spec_helper"
require "redsys-ruby"

RSpec.describe RedsysRuby::TPV do
  # A 32-byte key (256 bits), as provided by Redsys
  let(:merchant_key) { Base64.strict_encode64("a" * 32) }
  let(:tpv) { RedsysRuby::TPV.new(merchant_key: merchant_key) }

  describe "#initialize" do
    it "raises ArgumentError when merchant_key is missing or empty" do
      expect { RedsysRuby::TPV.new(merchant_key: nil) }.to raise_error(ArgumentError, "merchant_key is required")
      expect { RedsysRuby::TPV.new(merchant_key: "") }.to raise_error(ArgumentError, "merchant_key is required")
      expect { RedsysRuby::TPV.new(merchant_key: "   ") }.to raise_error(ArgumentError, "merchant_key is required")
    end
  end

  describe "#encrypt_3des" do
    let(:merchant_key) { "sq7HjrUOBfKmC576ILgskD5srU870gJ7" }
    let(:decoded_key) { Base64.decode64(merchant_key) }
    let(:order) { "140181510845" }
    let(:expected_derived_key_64) { "S/VinFar4wSYjr3RDeU00Q==" }

    it "correctly encrypts the order using DES-EDE3-CBC" do
      encrypted = tpv.encrypt_3des(order, decoded_key)
      expect(Base64.strict_encode64(encrypted)).to eq(expected_derived_key_64)
    end

    it "pads the order to a multiple of 8 bytes" do
      # "123" is 3 bytes, should be padded to 8 bytes with nulls
      # We can't easily see the padded order as it's internal, but we can verify the result length
      # 3DES output length is always multiple of 8 (since padding=0 and we manually pad to 8)
      expect(tpv.encrypt_3des("123", decoded_key).bytesize).to eq(8)
      expect(tpv.encrypt_3des("12345678", decoded_key).bytesize).to eq(8)
      expect(tpv.encrypt_3des("123456789", decoded_key).bytesize).to eq(16)
    end
  end

  describe "#generate_merchant_parameters" do
    it "encodes parameters to Base64" do
      params = { Ds_Merchant_Amount: "145", Ds_Merchant_Order: "1" }
      encoded = tpv.generate_merchant_parameters(params)
      expect(encoded).to eq(Base64.strict_encode64(params.to_json))
    end
  end

  describe "#generate_merchant_signature" do
    it "generates a signature" do
      params = { Ds_Merchant_Amount: "145", Ds_Merchant_Order: "1" }
      encoded_params = tpv.generate_merchant_parameters(params)
      signature = tpv.generate_merchant_signature("1", encoded_params)
      expect(signature).to be_a(String)
      expect(signature).not_to be_empty
    end
  end

  describe "#payment_data" do
    it "returns the necessary data for the Redsys form" do
      params = { Ds_Merchant_Amount: "145", Ds_Merchant_Order: "1" }
      data = tpv.payment_data(params)
      expect(data).to have_key(:Ds_SignatureVersion)
      expect(data).to have_key(:Ds_MerchantParameters)
      expect(data).to have_key(:Ds_Signature)
      expect(data[:Ds_SignatureVersion]).to eq("HMAC_SHA256_V1")
    end
  end

  describe "notification handling" do
    let(:params) { { Ds_Order: "1", Ds_Response: "0000" } }
    let(:encoded_params) { Base64.urlsafe_encode64(params.to_json) }
    let(:signature) { tpv.generate_merchant_signature_notif(encoded_params) }

    describe "#generate_merchant_signature_notif" do
      it "generates a urlsafe signature" do
        expect(signature).to be_a(String)
        # Check if it's urlsafe (doesn't contain + or /)
        expect(signature).not_to include("+")
        expect(signature).not_to include("/")
      end

      it "raises ArgumentError when order is missing" do
        params_without_order = { Ds_Response: "0000" }
        encoded_params_without_order = Base64.urlsafe_encode64(params_without_order.to_json)
        expect {
          tpv.generate_merchant_signature_notif(encoded_params_without_order)
        }.to raise_error(ArgumentError, /Order is missing/)
      end
    end

    describe "#valid_signature?" do
      it "returns true for a valid signature" do
        expect(tpv.valid_signature?(encoded_params, signature)).to be true
      end

      it "returns false for an invalid signature" do
        expect(tpv.valid_signature?(encoded_params, "invalid")).to be false
      end
    end

    describe "#decode_parameters" do
      it "decodes the parameters" do
        decoded = tpv.decode_parameters(encoded_params)
        expect(decoded).to eq(params.transform_keys(&:to_s))
      end
    end
  end
end
