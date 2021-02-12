# frozen_string_literal: true

require_relative "get_weather/version"
require "faraday"
require "json"

module GetWeather
  class Error < StandardError
  end
  
  $LAT = 41.936748
  $LONG = -88.069309
  $APPID = "a69d47752b3fca28f70d731e9447c84a"
  $UNIT = "imperial"

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
      @weather_data["sunrise"] = weather_hash["daily"][0]["sunrise"]
      @weather_data["sunset"] = weather_hash["daily"][0]["sunset"]
      @weather_data["temp"] = weather_hash["daily"][0]["temp"]["day"]
      @weather_data["feels like"] = weather_hash["daily"][0]["feels_like"]["day"]
      @weather_data["humidity"] = weather_hash["daily"][0]["humidity"]
      @weather_data["clouds"] = weather_hash["daily"][0]["clouds"]
      @weather_data["description"] = weather_hash["daily"][0]["weather"][0]["description"]
      to_s
    end

    def get_current(weather_hash)
      @weather_data["sunrise"] = weather_hash["current"]["sunrise"]
      @weather_data["sunset"] = weather_hash["current"]["sunset"]
      @weather_data["temp"] = weather_hash["current"]["temp"]
      @weather_data["feels like"] = weather_hash["current"]["feels_like"]
      @weather_data["humidity"] = weather_hash["current"]["humidity"]
      @weather_data["clouds"] = weather_hash["current"]["clouds"]
      @weather_data["description"] = weather_hash["current"]["weather"][0]["description"]
      to_s
    end

    def to_s
      <<-EOF
Weather for Lat: #{$LAT}, Long: #{$LONG}:

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
    response = client.get("/data/2.5/onecall?lat=#{$LAT}&lon=#{$LONG}&units=#{$UNIT}&exclude=hourly,minutely&appid=#{$APPID}")
    # vvvvvvvv DOES NOT WORK vvvvvvvv
    # resposne = client.get("/data/2.5/onecall?") do |req|
    #   req.params["lat"] = $LAT
    #   req.params["lon"] = $LONG
    #   req.params["units"] = $UNIT
    #   req.params["exclude"] = "hourly,minutely"
    #   req.params["appid"] = $APPID
    # end
    if response.success?
      weather_hash = JSON.parse(response.body)
      weather = Weather.new()
      output.puts weather.get_daily(weather_hash) if forecast.downcase == "daily"
      output.puts weather.get_current(weather_hash) if forecast.downcase == "current"
    else
      output.puts "400 - No Connection"
    end

    def self.faraday_client
      Faraday.new("https://api.openweathermap.org")
    end
  end

  if $0 == __FILE__
    Weather.get_weather
  end

end