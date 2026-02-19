class WeatherController < ApplicationController
  def index
    return unless params[:address]

    @address = params[:address]
    @weather = WeatherService.call(
      params[:address],
      params[:high_low].present?,
      params[:extended_forecast].presence
      )
  end
end
