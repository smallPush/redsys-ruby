# frozen_string_literal: true

require "openssl"
require "base64"
require "json"

module RedsysRuby
  class TPV
    PRODUCTION_URL = "https://sis.redsys.es/sis/realizarPago"
    TEST_URL = "https://sis-t.redsys.es:25443/sis/realizarPago"

    attr_reader :merchant_key

    def initialize(merchant_key:)
      raise ArgumentError, "merchant_key is required" if merchant_key.nil? || merchant_key.to_s.strip.empty?
      @merchant_key = merchant_key
    end

    def encrypt_3des(order, key)
      cipher = OpenSSL::Cipher.new("DES-EDE3-CBC")
      cipher.encrypt
      cipher.key = key[0..23]
      cipher.iv = "\0" * 8
      cipher.padding = 0

      # Redsys uses 8-byte blocks. The order must be padded with null bytes to a multiple of 8.
      padded_order = order.ljust((order.length + 7) / 8 * 8, "\0")
      cipher.update(padded_order) + cipher.final
    end

    def generate_merchant_parameters(params)
      json_params = params.to_json
      Base64.strict_encode64(json_params)
    end

    def generate_merchant_signature(order, merchant_parameters_64)
      digest = calculate_digest(order, merchant_parameters_64)
      Base64.strict_encode64(digest)
    end

    def payment_data(params)
      params = params.transform_keys(&:to_s)
      merchant_parameters_64 = generate_merchant_parameters(params)
      order = params["Ds_Merchant_Order"]
      
      {
        Ds_SignatureVersion: "HMAC_SHA256_V1",
        Ds_MerchantParameters: merchant_parameters_64,
        Ds_Signature: generate_merchant_signature(order.to_s, merchant_parameters_64)
      }
    end

    def generate_merchant_signature_notif(merchant_parameters_64)
      # For notifications, we need to extract the order from the decoded parameters.
      decoded_params = decode_parameters(merchant_parameters_64)
      order = decoded_params["Ds_Order"] || decoded_params["Ds_Merchant_Order"]
      
      raise ArgumentError, "Order is missing in merchant parameters" if order.nil?

      digest = calculate_digest(order, merchant_parameters_64)
      Base64.urlsafe_encode64(digest)
    end

    def valid_signature?(merchant_parameters_64, signature)
      expected_signature = generate_merchant_signature_notif(merchant_parameters_64)
      # We should use a constant-time comparison here for security
      secure_compare(expected_signature, signature)
    end

    def decode_parameters(merchant_parameters_64)
      JSON.parse(Base64.decode64(merchant_parameters_64))
    end

    private

    # Encrypts the order number with the merchant key using 3DES
    def encrypt_3des(order, key)
      cipher = OpenSSL::Cipher.new("DES-EDE3-CBC")
      cipher.encrypt
      cipher.key = key[0..23]
      cipher.iv = "\0" * 8
      cipher.padding = 0

      padded_order = order.ljust((order.length + 7) / 8 * 8, "\0")
      cipher.update(padded_order) + cipher.final
    end

    def calculate_digest(order, merchant_parameters_64)
      # 1. Decode the merchant key
      decoded_key = Base64.decode64(@merchant_key)

      # 2. Derive the key for this order
      derived_key = encrypt_3des(order, decoded_key)

      # 3. Calculate HMAC-SHA256
      OpenSSL::HMAC.digest("SHA256", derived_key, merchant_parameters_64)
    end

    def secure_compare(a, b)
      return false if a.empty? || b.empty? || a.bytesize != b.bytesize

      OpenSSL.fixed_length_secure_compare(a, b)
    end
  end
end
