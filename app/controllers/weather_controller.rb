class WeatherController < ApplicationController
  def index
    return unless params[:address]

    @address = params[:address]
    @weather = WeatherService.call(
      params[:address],
      params[:high_low].present?,
      params[:extended_forecast].presence
    )
  rescue WeatherService::InvalidAddressError
    flash[:alert] = 'Invalid address'
  rescue WeatherService::ApiError
    flash[:alert] = 'Weather service unavailable, try again later'
  end
end
