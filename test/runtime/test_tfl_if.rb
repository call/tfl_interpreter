require_relative '../test_helper'

class TestTflUpcaseDowncase < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_upcase_string
    assert_equal "HELLO", @context.tfl_UPCASE("hello")
  end

  def test_upcase_mixed_case
    assert_equal "HELLO WORLD", @context.tfl_UPCASE("HeLLo WoRLd")
  end

  def test_upcase_number
    assert_equal "123", @context.tfl_UPCASE(123)
  end

  def test_upcase_nil
    assert_equal :tfl_null_value, @context.tfl_UPCASE(nil)
  end

  def test_upcase_tfl_null
    assert_equal :tfl_null_value, @context.tfl_UPCASE(:tfl_null_value)
  end

  def test_downcase_string
    assert_equal "hello", @context.tfl_DOWNCASE("HELLO")
  end

  def test_downcase_mixed_case
    assert_equal "hello world", @context.tfl_DOWNCASE("HeLLo WoRLd")
  end

  def test_downcase_number
    assert_equal "123", @context.tfl_DOWNCASE(123)
  end

  def test_downcase_nil
    assert_equal :tfl_null_value, @context.tfl_DOWNCASE(nil)
  end

  def test_downcase_tfl_null
    assert_equal :tfl_null_value, @context.tfl_DOWNCASE(:tfl_null_value)
  end
end
