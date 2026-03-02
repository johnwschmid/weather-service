# Weather API

This is a simple weather API that accepts an address, and returns the current weather with additional options to return the highs/lows for the day as well as for an extended forecast of up to 16 days. The Open-Meteo API only accepts coordinates, so first Geocoder is used to transcribe the address into coordinates, and then a request with the sought after parameters is sent to the API and the data returned to the client. If the user enters a zipcode, the data is cached in redis using the zip as the key.

This application uses tailwind so the server is best run with 'bin/dev'
