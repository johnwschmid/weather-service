class WeatherService
  def initialize(address, high_low = false, extended_forecast = nil)
    @add = address
    @hl = high_low
    @ext = extended_forecast
  end

  def self.call(address, high_low = false, extended_forecast = nil)
    new(address, high_low = high_low, extended_forecast = extended_forecast).call
  end

  def call
    # get coordinates needed for weather API
    results = Geocoder.search @add
    coords = results.first.coordinates

    fetch_weather_data(coords)
  end

  private

  def fetch_weather_data(coords)
    uri = build_uri coords
    response = Net::HTTP.get uri
    parse_data response
  end

  def build_uri(coords)
    uri = URI 'https://api.open-meteo.com/v1/forecast'
    query_items = {
      latitude: coords[0],
      longitude: coords[1],
      current: 'temperature_2m',
      temperature_unit: 'fahrenheit',
      timezone: 'auto'
    }
    query_items[:daily] = 'temperature_2m_max,temperature_2m_min' if @hl.present?
    query_items[:forecast_days] = @ext if @ext.present?
    uri.query = URI.encode_www_form query_items
    uri
  end

  def parse_data(response)
    results = {}
    json = JSON.parse response

    results['current_temp'] = json.dig('current', 'temperature_2m')
    parse_highs_lows json, results if @hl.present?

    # only pick current day's temps unless user wants extended forecast
    # by default open-meteo returns 7 days of highs/lows if extended forecast is not specified
    results['highs_lows'] = results['highs_lows'].first unless @ext.present?

    results
  end

  def parse_highs_lows(json, results)
    hls = {}
    day = json['daily']['time']
    min_temp = json['daily']['temperature_2m_min']
    max_temp = json['daily']['temperature_2m_max']
    json['daily']['time'].length.times do |idx|
      hls[day[idx]] = [min_temp[idx], max_temp[idx]]
    end
    results['highs_lows'] = hls
  end
end
