# frozen_string_literal: true

require "bigdecimal"
require "bigdecimal/util"
require_relative "redsys-ruby/version"
require_relative "redsys-ruby/tpv"
require_relative "redsys-ruby/engine" if defined?(Rails)

module RedsysRuby
  class Error < StandardError; end
  # Your code goes here...
end
