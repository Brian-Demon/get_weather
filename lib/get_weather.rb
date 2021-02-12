# frozen_string_literal: true

require_relative "get_weather/version"
require "faraday"
require "json"

module GetWeather
  class Error < StandardError
  end
  
  LAT = 41.936748
  LONG = -88.069309
  APPID = "a69d47752b3fca28f70d731e9447c84a"
  UNIT = "imperial"

  class Weather
    attr_reader :weather_data

    def initialize()
      @weather_data = get_weather_data_hash
    end

    def get_weather_data_hash
      {
        "sunrise" => "no data",
        "sunset" => "no data",
        "temp" => "no data",
        "feels like" => "no data",
        "humidity" => "no data",
        "clouds" => "no data",
        "weather description" => "no data"
      }
    end

    def get_daily(weather_hash)
      daily_data = weather_hash["daily"][0]
      @weather_data["sunrise"] = daily_data["sunrise"]
      @weather_data["sunset"] = daily_data["sunset"]
      @weather_data["temp"] = daily_data["temp"]["day"]
      @weather_data["feels like"] = daily_data["feels_like"]["day"]
      @weather_data["humidity"] = daily_data["humidity"]
      @weather_data["clouds"] = daily_data["clouds"]
      @weather_data["description"] = daily_data["weather"][0]["description"]
      to_s
    end

    def get_current(weather_hash)
      current_data = weather_hash["current"]
      @weather_data["sunrise"] = current_data["sunrise"]
      @weather_data["sunset"] = current_data["sunset"]
      @weather_data["temp"] = current_data["temp"]
      @weather_data["feels like"] = current_data["feels_like"]
      @weather_data["humidity"] = current_data["humidity"]
      @weather_data["clouds"] = current_data["clouds"]
      @weather_data["description"] = current_data["weather"][0]["description"]
      to_s
    end

    def to_s
      <<-EOF
Weather for Lat: #{GetWeather::LAT}, Long: #{GetWeather::LONG}:

Temperature: #{@weather_data["temp"]}ºF
Weather: #{@weather_data["description"]}
Feels Like: #{@weather_data["feels like"]}ºF
Humidity: #{@weather_data["humidity"]}%
Clouds Coverage: #{@weather_data["clouds"]}%
Sunrise at #{@weather_data["sunrise"]}
Sunset at #{@weather_data["sunset"]}
EOF
    end
  end

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