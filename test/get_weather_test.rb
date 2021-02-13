# frozen_string_literal: true

require "test_helper"
require "stringio"

class GetWeatherTest < Minitest::Test
  def canned_weather_hash
    {
      "lat" => 41.936748,
      "lon" => -88.069309,
      "timezone" => "America/Chicago",
      "timezone_offset" => -21600,
      "current" => {
        "dt" => 1595243443,
        "sunrise" => 1608124431,
        "sunset" => 1608160224,
        "temp" => "10",
        "feels_like" => 270.4,
        "pressure" => 1017,
        "humidity" => 96,
        "dew_point" => 274.18,
        "uvi" => 0,
        "clouds" => 90,
        "visibility" => 6437,
        "wind_speed" => 3.6,
        "wind_deg" => 320,
        "weather" => [
          {
            "id" => 701,
            "main" => "Mist",
            "description": "mist",
            "icon" => "50n"
          }
        ]
      },
      "daily" => [
        {
          "dt" => 1595268000,
          "sunrise" => 1608124431,
          "sunset" => 1608160224,
          "temp" => {
            "day" => "2",
            "min" => 273.15,
            "max" => 279.4,
            "night": 273.15,
            "eve": 275.82,
            "morn": 275.35
          },
          "feels_like" => {
            "day" => 273.53,
            "night": 270.26,
            "eve": 271.89,
            "morn": 272.11
          },
          "pressure": 1021,
          "humidity": 70,
          "dew_point": 273.27,
          "wind_speed": 3.74,
          "wind_deg": 323,
          "weather" => [
            {
              "id": 803,
              "main": "Clouds",
              "description": "broken clouds",
              "icon": "04d"
            }
          ],
          "clouds": 60,
          "pop": 0.84,
          "uvi": 2.41
        }
      ],
      "alerts": [
          {
            "sender_name": "NWS Tulsa (Eastern Oklahoma)",
            "event": "Heat Advisory",
            "start": 1597341600,
            "end": 1597366800,
            "description": "...HEAT ADVISORY REMAINS IN EFFECT FROM 1 PM THIS AFTERNOON TO\n8 PM CDT THIS EVENING...\n* WHAT...Heat index values of 105 to 109 degrees expected.\n* WHERE...Creek, Okfuskee, Okmulgee, McIntosh, Pittsburg,\nLatimer, Pushmataha, and Choctaw Counties.\n* WHEN...From 1 PM to 8 PM CDT Thursday.\n* IMPACTS...The combination of hot temperatures and high\nhumidity will combine to create a dangerous situation in which\nheat illnesses are possible."
          }
        ]
    }
  end

  def test_that_it_has_a_version_number
    refute_nil ::GetWeather::VERSION
  end

  def get_output_client_hash
    output = StringIO.new
    client = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.get("/data/2.5/onecall?lat=#{41.936748}&lon=#{-88.069309}&appid=#{"a69d47752b3fca28f70d731e9447c84a"}") { |env| [200, {}, JSON.generate(canned_weather_hash)] }
      end
    end
    { "output" => output, "client" => client }
  end

  def test_gets_successful_response_from_API
    #skip
    output_client_hash = get_output_client_hash
    output = output_client_hash["output"]
    client = output_client_hash["client"]
    forecast = "daily"
    GetWeather.get_weather(output: output, client: client, forecast: forecast)
    output.rewind
    should_not_equal = "Not successful"
    assert_equal true, should_not_equal != output.read.chomp
  end

  def test_that_get_daily_prints_temp_and_weather
    #skip
    output_client_hash = get_output_client_hash
    output = output_client_hash["output"]
    client = output_client_hash["client"]
    forecast = "daily"
    GetWeather.get_weather(output: output, client: client, forecast: forecast)   
    output.rewind
    expected = "Weather for Lat: 41.936748, Long: -88.069309: 2ºF, broken clouds"
    assert_equal expected, output.read.chomp
  end

  def test_that_get_current_prints_temp_and_weather
    #skip
    output_client_hash = get_output_client_hash
    output = output_client_hash["output"]
    client = output_client_hash["client"]
    forecast = "current"
    GetWeather.get_weather(output: output, client: client, forecast: forecast)   
    output.rewind
    expected = "Weather for Lat: 41.936748, Long: -88.069309: 10ºF, mist"
    assert_equal expected, output.read.chomp
  end

end