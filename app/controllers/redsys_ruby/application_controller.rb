# frozen_string_literal: true

module RedsysRuby
  class ApplicationController < RedsysRuby.parent_controller.constantize
    layout "application"
  end
end
