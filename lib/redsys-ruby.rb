# frozen_string_literal: true

require "securerandom"
require_relative "redsys-ruby/version"
require_relative "redsys-ruby/tpv"
require_relative "redsys-ruby/engine" if defined?(Rails)

module RedsysRuby
  class Error < StandardError; end

  class << self
    def configure
      yield self
    end

    attr_accessor :parent_controller
    attr_accessor :before_configuration_action
  end

  # Set defaults
  self.parent_controller = "ActionController::Base"
  self.before_configuration_action = nil
end
