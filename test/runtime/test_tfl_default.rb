require_relative '../test_helper'

class TestTflDefault < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_default_with_value
    assert_equal "value", @context.tfl_DEFAULT("value", "fallback")
  end

  def test_default_with_nil
    assert_equal "fallback", @context.tfl_DEFAULT(nil, "fallback")
  end

  def test_default_with_tfl_null
    assert_equal "fallback", @context.tfl_DEFAULT(:tfl_null_value, "fallback")
  end

  def test_default_with_empty_string
    assert_equal "", @context.tfl_DEFAULT("", "fallback")
  end

  def test_default_with_false
    assert_equal false, @context.tfl_DEFAULT(false, "fallback")
  end

  def test_default_with_zero
    assert_equal 0, @context.tfl_DEFAULT(0, "fallback")
  end

  def test_default_with_empty_array
    assert_equal [], @context.tfl_DEFAULT([], "fallback")
  end
end
