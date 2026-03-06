# frozen_string_literal: true

module RedsysRuby
  class PaymentsController < ApplicationController
    def index
      @order_id = SecureRandom.random_number(10**12).to_s.rjust(12, "0")
      @amount = 10.50
    end

    def ok
    end

    def ko
    end
  end
end
