require_relative '../test_helper'

class TestTflDate < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_date_with_unix_timestamp
    result = @context.tfl_DATE(1609459200, "%Y-%m-%d")
    assert_equal "2021-01-01", result
  end

  def test_date_with_string
    result = @context.tfl_DATE("2024-06-15", "%Y-%m-%d")
    assert_equal "2024-06-15", result
  end

  def test_date_with_time_object
    time = Time.new(2024, 6, 15, 12, 0, 0)
    result = @context.tfl_DATE(time, "%Y-%m-%d")
    assert_equal "2024-06-15", result
  end

  def test_date_with_natural_language
    result = @context.tfl_DATE("yesterday", "%Y-%m-%d")
    refute_nil result
    refute_equal :tfl_null_value, result
  end

  def test_date_default_format
    result = @context.tfl_DATE("2024-06-15")
    assert_match /2024-06-15/, result # ISO8601 format
  end

  def test_date_with_timezone
    result = @context.tfl_DATE("2024-06-15 12:00:00", "%Y-%m-%d %H:%M:%S", "America/New_York")
    refute_nil result
    refute_equal :tfl_null_value, result
  end

  def test_date_with_invalid_timezone
    result = @context.tfl_DATE("2024-06-15", "%Y-%m-%d", "Invalid/Timezone")
    assert_equal :tfl_null_value, result
  end

  def test_date_with_nil
    assert_equal :tfl_null_value, @context.tfl_DATE(nil)
  end

  def test_date_with_tfl_null
    assert_equal :tfl_null_value, @context.tfl_DATE(:tfl_null_value)
  end

  def test_date_with_unparseable_string
    result = @context.tfl_DATE("not a date", "%Y-%m-%d")
    assert_equal :tfl_null_value, result
  end

  def test_date_with_eu_format
    # Tests that "01/02/2023" is parsed as Feb 1, 2023 (EU format)
    result = @context.tfl_DATE("01/02/2023", "%Y-%m-%d")
    assert_equal "2023-02-01", result
  end
end
