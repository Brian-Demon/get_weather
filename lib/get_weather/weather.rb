module GetWeather
  class Weather
    attr_reader :weather_data

    def initialize(timezone = "America/Chicago")
      @weather_data = get_weather_data_hash
      @timezone = TZInfo::Timezone.get(timezone)
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

    def epoch_to_local(time)
      @timezone.to_local(Time.at(time))
    end

    def get_daily(weather_hash)
      daily_data = weather_hash["daily"][0]
      @weather_data["sunrise"] = epoch_to_local(daily_data["sunrise"])
      @weather_data["sunset"] = epoch_to_local(daily_data["sunset"])
      @weather_data["temp"] = daily_data["temp"]["day"]
      @weather_data["feels like"] = daily_data["feels_like"]["day"]
      @weather_data["humidity"] = daily_data["humidity"]
      @weather_data["clouds"] = daily_data["clouds"]
      @weather_data["description"] = daily_data["weather"][0]["description"]
      to_s
    end

    def get_current(weather_hash)
      current_data = weather_hash["current"]
      @weather_data["sunrise"] = epoch_to_local(current_data["sunrise"])
      @weather_data["sunset"] = epoch_to_local(current_data["sunset"])
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
end