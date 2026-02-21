describe WeatherController do
  describe 'GET #index' do
    before do
      allow(WeatherService).to receive(:call).and_return({ temp: 20 })
    end
    context 'returns current weather' do
      expect
    end
  end
end