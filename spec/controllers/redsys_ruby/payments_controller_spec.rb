require "spec_helper"
require "rails"
require "action_controller"
require "action_dispatch/testing/test_process"
require "action_dispatch/testing/test_request"
require "action_dispatch/testing/test_response"

# Mock necessary Rails classes for testing the controller without a full Rails app
module RedsysRuby
  class ApplicationController < ActionController::Base
  end
end

require_relative "../../../app/controllers/redsys_ruby/payments_controller"

RSpec.describe RedsysRuby::PaymentsController, type: :controller do
  let(:controller) { described_class.new }
  let(:request) { ActionDispatch::TestRequest.create }
  let(:response) { ActionDispatch::TestResponse.new }

  before do
    # Stub default render to avoid MissingTemplate errors since we have no views in this test setup
    allow(controller).to receive(:default_render)
  end

  describe "GET #index" do
    it "returns success" do
      controller.dispatch(:index, request, response)
      expect(response.status).to eq(200)
    end

    it "generates a secure order_id of exactly 12 characters" do
      controller.dispatch(:index, request, response)
      order_id = controller.instance_variable_get(:@order_id)

      expect(order_id).to be_a(String)
      expect(order_id.length).to eq(12)
      expect(order_id).to match(/^\d{12}$/)
    end

    it "generates different order_ids on subsequent calls" do
      controller.dispatch(:index, request, response)
      order_id1 = controller.instance_variable_get(:@order_id)

      controller.dispatch(:index, request, response)
      order_id2 = controller.instance_variable_get(:@order_id)

      expect(order_id1).not_to eq(order_id2)
    end
  end

  describe "GET #ok" do
    it "returns success" do
      controller.dispatch(:ok, request, response)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #ko" do
    it "returns success" do
      controller.dispatch(:ko, request, response)
      expect(response.status).to eq(200)
    end
  end
end
