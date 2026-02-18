# frozen_string_literal: true

RedsysRuby::Engine.routes.draw do
  resource :configuration, only: [:edit, :update]
  root to: "configurations#edit"
end
