# frozen_string_literal: true

require "test_helper"
require "stringio"

class GetWeatherTest < Minitest::Test
  def canned_weather_hash
    {
      "current" => {
        "temp" => "10",
        "weather" => [
          {
            "description" => "Blizzard"
          }
        ]
      },
      "daily" => [
        {
          "temp" => {
            "day" => "2"
            },
          "weather" => [
            {
              "description" => "Snow"
            }
          ]
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
    expected = "Weather for Lat: 41.936748, Long: -88.069309: 2ºF, Snow"
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
    expected = "Weather for Lat: 41.936748, Long: -88.069309: 10ºF, Blizzard"
    assert_equal expected, output.read.chomp
  end

end