# frozen_string_literal: true

require_relative "get_weather/version"
require "faraday"
require "json"
require "get_weather/weather"
require "tzinfo"

module GetWeather
  class Error < StandardError
  end
  
  LAT = 41.936748
  LONG = -88.069309
  APPID = "a69d47752b3fca28f70d731e9447c84a"
  UNIT = "imperial"

  def self.get_weather(output: $stdout, client: faraday_client, forecast: forecast_passed)
    response = client.get("/data/2.5/onecall?") do |req|
      req.params["lat"] = LAT
      req.params["lon"] = LONG
      req.params["units"] = UNIT
      req.params["exclude"] = "hourly,minutely"
      req.params["appid"] = APPID
    end
    if response.success?
      weather_hash = JSON.parse(response.body)
      weather = Weather.new()
      output.puts weather.get_daily(weather_hash) if forecast.downcase == "daily"
      output.puts weather.get_current(weather_hash) if forecast.downcase == "current"
    else
      output.puts "400 - No Connection"
    end
  end

  def self.faraday_client
    Faraday.new("https://api.openweathermap.org")
  end

end

if $0 == __FILE__
  Weather.get_weather
end