require 'rails_helper'

describe WeatherService do
  describe '.call' do
    let(:address) { '123 Park Ave, New York, NY' }
    let(:mocked_geocode_res) do
      instance_double('Geocoder::Result::Google', coordinates: [40.7523002, -73.976725])
    end
    let(:mocked_api_response) do
      instance_double(Net::HTTPResponse, code: '200', body: api_response)
    end
    context 'when address is invalid' do
      before do
        allow(Geocoder).to receive(:search).with('').and_return([])
      end
      it 'returns an error' do
        expect { WeatherService.call('') }.to raise_error(WeatherService::InvalidAddressError)
      end
    end
    context 'when address is valid' do
      let(:uri) { URI 'https://api.open-meteo.com/v1/forecast?latitude=40.7523002&longitude=-73.976725&current=temperature_2m&temperature_unit=fahrenheit&timezone=auto' }
      let(:api_response) do
        "{\"latitude\":40.762505,\"longitude\":-73.975105,\"generationtime_ms\":0.02491474151611328,\"utc_offset_seconds\":-18000,\"timezone\":\"America/New_York\",\"timezone_abbreviation\":\"GMT-5\",\"elevation\":83.0,\"current_units\":{\"time\":\"iso8601\",\"interval\":\"seconds\",\"temperature_2m\":\"\xC2\xB0F\"},\"current\":{\"time\":\"2026-02-23T23:15\",\"interval\":900,\"temperature_2m\":21.8}}"
      end
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mocked_geocode_res])
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(mocked_api_response)
      end
      it 'returns current temp' do
        expect(WeatherService.call(address, false)).to eq({ 'current_temp' => 21.8, 'highs_lows' => nil })
      end
    end
    context 'when address is valid and high/low is true' do
      let(:uri) { URI 'https://api.open-meteo.com/v1/forecast?latitude=40.7523002&longitude=-73.976725&current=temperature_2m&temperature_unit=fahrenheit&timezone=auto&daily=temperature_2m_max%2Ctemperature_2m_min' }
      let(:api_response) do
        "{\"latitude\":40.762505,\"longitude\":-73.975105,\"generationtime_ms\":0.07271766662597656,\"utc_offset_seconds\":-18000,\"timezone\":\"America/New_York\",\"timezone_abbreviation\":\"GMT-5\",\"elevation\":83.0,\"current_units\":{\"time\":\"iso8601\",\"interval\":\"seconds\",\"temperature_2m\":\"\xC2\xB0F\"},\"current\":{\"time\":\"2026-02-25T21:45\",\"interval\":900,\"temperature_2m\":29.4},\"daily_units\":{\"time\":\"iso8601\",\"temperature_2m_max\":\"\xC2\xB0F\",\"temperature_2m_min\":\"\xC2\xB0F\"},\"daily\":{\"time\":[\"2026-02-25\",\"2026-02-26\",\"2026-02-27\",\"2026-02-28\",\"2026-03-01\",\"2026-03-02\",\"2026-03-03\"],\"temperature_2m_max\":[39.6,38.5,37.9,45.8,39.6,26.3,29.2],\"temperature_2m_min\":[18.9,17.1,18.2,30.2,26.6,18.7,16.0]}}"
      end
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mocked_geocode_res])
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(mocked_api_response)
      end
      it 'returns current temp and high/low' do
        expect(WeatherService.call(address, '1')).to eq({ 'current_temp' => 29.4, 'highs_lows' => ['2026-02-25', [18.9, 39.6]] })
      end
    end
    context 'when address, high/low, and extended forecast is valid' do
      let(:uri) { URI 'https://api.open-meteo.com/v1/forecast?latitude=40.7523002&longitude=-73.976725&current=temperature_2m&temperature_unit=fahrenheit&timezone=auto&daily=temperature_2m_max%2Ctemperature_2m_min&forecast_days=3' }
      let(:api_response) do
        "{\"latitude\":40.762505,\"longitude\":-73.975105,\"generationtime_ms\":0.07462501525878906,\"utc_offset_seconds\":-18000,\"timezone\":\"America/New_York\",\"timezone_abbreviation\":\"GMT-5\",\"elevation\":83.0,\"current_units\":{\"time\":\"iso8601\",\"interval\":\"seconds\",\"temperature_2m\":\"\xC2\xB0F\"},\"current\":{\"time\":\"2026-02-25T22:00\",\"interval\":900,\"temperature_2m\":29.9},\"daily_units\":{\"time\":\"iso8601\",\"temperature_2m_max\":\"\xC2\xB0F\",\"temperature_2m_min\":\"\xC2\xB0F\"},\"daily\":{\"time\":[\"2026-02-25\",\"2026-02-26\",\"2026-02-27\"],\"temperature_2m_max\":[39.6,38.5,37.9],\"temperature_2m_min\":[18.9,17.1,18.2]}}"
      end
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mocked_geocode_res])
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(mocked_api_response)
      end
      it 'returns all option data' do
        expect(WeatherService.call(address, '1', 3)).to eq({ 'current_temp' => 29.9, 'highs_lows' => { '2026-02-25' => [18.9, 39.6], '2026-02-26' => [17.1, 38.5], '2026-02-27' => [18.2, 37.9] } })
      end
    end
    context 'when api fails' do
      let(:uri) { URI 'https://api.open-meteo.com/v1/forecast?latitude=40.7523002&longitude=-73.976725&current=temperature_2m&temperature_unit=fahrenheit&timezone=auto' }
      let(:mocked_api_response) do
        instance_double(Net::HTTPResponse, code: '1', body: '')
      end
      before do
        allow(Geocoder).to receive(:search).with(address).and_return([mocked_geocode_res])
        allow(Net::HTTP).to receive(:get_response).with(uri).and_return(mocked_api_response)
      end
      it 'returns api error' do
        expect { WeatherService.call(address) }.to raise_error(WeatherService::ApiError)
      end
    end
  end
end
