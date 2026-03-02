# frozen_string_literal: true

require "spec_helper"

RSpec.describe RedsysRuby do
  describe ".configure" do
    after do
      # Reset configuration to defaults after each test
      RedsysRuby.parent_controller = "ActionController::Base"
      RedsysRuby.before_configuration_action = nil
    end

    it "yields the RedsysRuby module" do
      expect { |b| RedsysRuby.configure(&b) }.to yield_with_args(RedsysRuby)
    end

    it "allows setting the parent_controller" do
      RedsysRuby.configure do |config|
        config.parent_controller = "MyCustomController"
      end
      expect(RedsysRuby.parent_controller).to eq("MyCustomController")
    end

    it "allows setting the before_configuration_action" do
      custom_action = -> { "test" }
      RedsysRuby.configure do |config|
        config.before_configuration_action = custom_action
      end
      expect(RedsysRuby.before_configuration_action).to eq(custom_action)
    end

    it "has default values" do
      expect(RedsysRuby.parent_controller).to eq("ActionController::Base")
      expect(RedsysRuby.before_configuration_action).to be_nil
    end
  end
end
