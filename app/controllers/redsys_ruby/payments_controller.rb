# frozen_string_literal: true

module RedsysRuby
  class PaymentsController < ApplicationController
    def index
      @order_id = Time.now.to_i.to_s[-12..-1] # Redsys order must be max 12 chars
      @amount = 10.50
    end

    def ok
    end

    def ko
    end
  end
end
