# frozen_string_literal: true

require "spec_helper"

RSpec.describe RedsysRuby do
  describe ".configure" do
    let!(:original_parent_controller) { RedsysRuby.parent_controller }
    let!(:original_before_action) { RedsysRuby.before_configuration_action }

    after do
      # Reset configuration to avoid affecting other tests
      RedsysRuby.parent_controller = original_parent_controller
      RedsysRuby.before_configuration_action = original_before_action
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
      my_proc = -> { "test" }
      RedsysRuby.configure do |config|
        config.before_configuration_action = my_proc
      end
      expect(RedsysRuby.before_configuration_action).to eq(my_proc)
    end
  end

  describe "default values" do
    it "has a default parent_controller" do
      expect(RedsysRuby.parent_controller).to eq("ActionController::Base")
    end

    it "has a safe default before_configuration_action" do
      expect(RedsysRuby.before_configuration_action).to be_a(Proc)
      expect { RedsysRuby.before_configuration_action.call }.to raise_error(
        RedsysRuby::Error,
        "Access denied. Please configure RedsysRuby.before_configuration_action."
      )
    end
  end
end
