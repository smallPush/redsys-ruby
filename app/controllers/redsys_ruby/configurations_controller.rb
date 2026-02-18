# frozen_string_literal: true

module RedsysRuby
  class ConfigurationsController < ActionController::Base
    layout "application"

    def edit
      @configuration = Configuration.load
    end

    def update
      @configuration = Configuration.new(configuration_params)
      if @configuration.save
        redirect_to edit_configuration_path, notice: "Configuración actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def configuration_params
      params.require(:configuration).permit(:merchant_key, :merchant_code, :terminal, :environment)
    end
  end
end
