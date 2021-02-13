# frozen_string_literal: true

require "test_helper"

class GetWeather::WeatherTest < Minitest::Test
  def test_epoch_to_local_converts_default_timezone
    weather = GetWeather::Weather.new
    expected = Time.at(946702800)
    assert_equal expected, weather.epoch_to_local(Time.at(946702800))
  end

  def test_epoch_to_local_converts_passed_timezone
    weather = GetWeather::Weather.new("America/Los_Angeles")
    input = Time.now.utc
    expected = input.getlocal("-08:00")
    assert_equal expected.to_i, weather.epoch_to_local(input.to_i).to_i
  end
end