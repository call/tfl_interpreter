require_relative '../test_helper'

class TestTflNot < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_not_false
    assert_equal true, @context.tfl_NOT(false)
  end

  def test_not_true
    assert_equal false, @context.tfl_NOT(true)
  end

  def test_not_tfl_null
    assert_equal true, @context.tfl_NOT(:tfl_null_value)
  end

  def test_not_nil
    # In TFL, nil is converted to TFL_NULL which is falsy
    assert_equal false, @context.tfl_NOT(nil)
  end

  def test_not_zero_is_truthy
    assert_equal false, @context.tfl_NOT(0)
  end

  def test_not_empty_string_is_truthy
    assert_equal false, @context.tfl_NOT("")
  end

  def test_not_empty_array_is_truthy
    assert_equal false, @context.tfl_NOT([])
  end

  def test_not_non_empty_string
    assert_equal false, @context.tfl_NOT("hello")
  end

  def test_not_positive_number
    assert_equal false, @context.tfl_NOT(42)
  end

  def test_not_negative_number
    assert_equal false, @context.tfl_NOT(-1)
  end

  def test_not_array
    assert_equal false, @context.tfl_NOT([1, 2, 3])
  end

  def test_not_hash
    assert_equal false, @context.tfl_NOT({ "key" => "value" })
  end

  def test_double_not_false
    assert_equal false, @context.tfl_NOT(@context.tfl_NOT(false))
  end

  def test_double_not_true
    assert_equal true, @context.tfl_NOT(@context.tfl_NOT(true))
  end
end
