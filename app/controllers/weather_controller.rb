class WeatherController < ApplicationController
  def index
    return unless params[:address]

    @address = params[:address]
    zipcode = @address.match(/\d{5}/)&.to_s
    @weather = if zipcode
                 Rails.cache.fetch(zipcode, expires_in: 30.minutes) do
                   fetch_weather
                 end
               else
                 # incase address does not include zip, run service without caching
                 fetch_weather
               end
  rescue WeatherService::InvalidAddressError
    flash[:alert] = 'Invalid address'
  rescue WeatherService::ApiError
    flash[:alert] = 'Weather service unavailable, try again later'
  end

  private

  def fetch_weather
    WeatherService.call(
      params[:address],
      params[:high_low] == '1',
      params[:extended_forecast].presence
    )
  end
end
