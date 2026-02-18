# frozen_string_literal: true

module RedsysRuby
  module PaymentsHelper
    def redsys_payment_form(amount:, order: nil, description: nil, button_text: "Pagar con Redsys", button_class: "redsys-submit")
      config = Configuration.load
      tpv = TPV.new(merchant_key: config.merchant_key)

      order ||= rand(10000..99999).to_s

      params = {
        Ds_Merchant_Amount: (amount.to_f * 100).to_i.to_s,
        Ds_Merchant_Order: order.to_s,
        Ds_Merchant_MerchantCode: config.merchant_code,
        Ds_Merchant_Currency: "978", # EUR
        Ds_Merchant_TransactionType: "0", # Autorización
        Ds_Merchant_Terminal: config.terminal,
        Ds_Merchant_MerchantURL: "", # Should be configured or passed
        Ds_Merchant_UrlOK: RedsysRuby::Engine.routes.url_helpers.ok_payments_url(host: request.base_url),
        Ds_Merchant_UrlKO: RedsysRuby::Engine.routes.url_helpers.ko_payments_url(host: request.base_url)
      }

      params[:Ds_Merchant_ProductDescription] = description if description.present?

      payment_data = tpv.payment_data(params)
      url = config.environment == "production" ? TPV::PRODUCTION_URL : TPV::TEST_URL

      form_with url: url, method: :post, local: true, html: { id: "redsys_payment_form" } do |f|
        concat f.hidden_field :Ds_SignatureVersion, value: payment_data[:Ds_SignatureVersion]
        concat f.hidden_field :Ds_MerchantParameters, value: payment_data[:Ds_MerchantParameters]
        concat f.hidden_field :Ds_Signature, value: payment_data[:Ds_Signature]
        concat f.submit button_text, class: button_class
      end
    end
  end
end
