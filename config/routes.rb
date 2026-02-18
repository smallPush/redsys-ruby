# frozen_string_literal: true

RedsysRuby::Engine.routes.draw do
  resource :configuration, only: [:edit, :update]
  resources :payments, only: [:index] do
    collection do
      get :ok
      get :ko
    end
  end
  root to: "configurations#edit"
end
