require "spec_helper"
require "rails"
require "action_controller"

# Mock necessary Rails classes for testing the controller without a full Rails app
module RedsysRuby
  class ApplicationController < ActionController::Base
  end
end

require_relative "../../../app/controllers/redsys_ruby/payments_controller"

RSpec.describe RedsysRuby::PaymentsController, type: :controller do
  describe "#index" do
    it "generates a secure order_id of exactly 12 characters" do
      controller = RedsysRuby::PaymentsController.new
      controller.index

      order_id = controller.instance_variable_get(:@order_id)

      expect(order_id).to be_a(String)
      expect(order_id.length).to eq(12)
      expect(order_id).to match(/^\d{12}$/)
    end

    it "generates different order_ids on subsequent calls" do
      controller = RedsysRuby::PaymentsController.new

      controller.index
      order_id1 = controller.instance_variable_get(:@order_id)

      controller.index
      order_id2 = controller.instance_variable_get(:@order_id)

      expect(order_id1).not_to eq(order_id2)
    end
  end
end
