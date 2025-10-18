require_relative '../e2e_test_helper'

class TestE2EDateOperations < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "timestamp" => 1609459200,
      "date_string" => "2024-06-15",
      "eu_date" => "01/02/2023"
    })
  end

  def test_date_from_timestamp
    result = @context.execute_tfl('DATE(timestamp, "%Y-%m-%d")')
    assert_equal "2021-01-01", result
  end

  def test_date_from_string
    result = @context.execute_tfl('DATE(date_string, "%Y-%m-%d")')
    assert_equal "2024-06-15", result
  end

  def test_date_default_format
    result = @context.execute_tfl('DATE(date_string)')
    assert_match /2024-06-15/, result
  end

  def test_date_eu_format
    result = @context.execute_tfl('DATE(eu_date, "%Y-%m-%d")')
    assert_equal "2023-02-01", result # DD/MM/YYYY interpreted as Feb 1st
  end

  def test_date_custom_format
    result = @context.execute_tfl('DATE(date_string, "%d/%m/%Y")')
    assert_equal "15/06/2024", result
  end

  def test_date_with_invalid_input
    result = @context.execute_tfl('DATE(missing_date, "%Y-%m-%d")')
    assert_equal :tfl_null_value, result
  end
end
