# frozen_string_literal: true

require_relative "get_weather/version"
require "faraday"
require "json"

module GetWeather
  class Error < StandardError
  end
  
  class Weather
    attr_reader :temp, :description

    $LAT = 41.936748
    $LONG = -88.069309
    $APPID = "a69d47752b3fca28f70d731e9447c84a"

    def initialize()
      @temp = "No Temp Yet!"
      @description = "No Description Yet!"
    end

    def get_daily(weather_hash)
      @temp = weather_hash["daily"][0]["temp"]["day"]
      @description = weather_hash["daily"][0]["weather"][0]["description"]
      to_s
    end

    def get_current(weather_hash)
      @temp = weather_hash["current"]["temp"]
      @description = weather_hash["current"]["weather"][0]["description"]
      to_s
    end

    def to_s
      <<-EOF
Weather for Lat: #{$LAT}, Long: #{$LONG}: #{@temp}ºF, #{@description}
      EOF
    end
  end

  def self.get_weather(output: $stdout, client: faraday_client, forecast: forecast_passed)
    response = client.get("/data/2.5/onecall?lat=#{$LAT}&lon=#{$LONG}&appid=#{$APPID}")
    if response.success?
      weather_hash = JSON.parse(response.body)
      weather = Weather.new()
      output.puts weather.get_daily(weather_hash) if forecast.downcase == "daily"
      output.puts weather.get_current(weather_hash) if forecast.downcase == "current"
    else
      output.puts "Not successful"
    end

    def self.faraday_client
      Faraday.new("https://api.openweathermap.org")
    end
  end

  if $0 == __FILE__
    Weather.get_weather
  end

end