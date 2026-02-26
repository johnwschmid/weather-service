require 'rails_helper'

describe WeatherController, type: :controller do
  describe 'GET #index' do
    let(:address) { '123 Park Ave, New York, NY' }
    let(:uri) { URI 'https://api.open-meteo.com/v1/forecast?latitude=40.7523002&longitude=-73.976725&current=temperature_2m&temperature_unit=fahrenheit&timezone=auto' }
    let(:api_response) do
      "{\"latitude\":40.762505,\"longitude\":-73.975105,\"generationtime_ms\":0.02491474151611328,\"utc_offset_seconds\":-18000,\"timezone\":\"America/New_York\",\"timezone_abbreviation\":\"GMT-5\",\"elevation\":83.0,\"current_units\":{\"time\":\"iso8601\",\"interval\":\"seconds\",\"temperature_2m\":\"\xC2\xB0F\"},\"current\":{\"time\":\"2026-02-23T23:15\",\"interval\":900,\"temperature_2m\":21.8}}"
    end

    let(:mocked_geocode_res) do
      instance_double('Geocoder::Result::Google', coordinates: [40.7523002, -73.976725])
    end

    before do
      allow(Geocoder).to receive(:search).with(address).and_return([mocked_geocode_res])
      allow(Net::HTTP).to receive(:get).with(uri).and_return(api_response)
    end

    it 'returns current temp when just address is passed' do
      get :index, params: { address: address }
      expect(response).to have_http_status(:ok)
      expect(assigns(:weather)['current_temp']).to eq(21.8)
    end
  end
end
