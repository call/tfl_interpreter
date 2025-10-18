require_relative '../test_helper'

class TestTflAppend < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_append_two_strings
    assert_equal "appending", @context.tfl_APPEND("app", "ending")
  end

  def test_append_multiple_strings
    assert_equal "appending", @context.tfl_APPEND("app", "end", "ing")
  end

  def test_append_with_numbers
    assert_equal "123", @context.tfl_APPEND(1, 2, 3)
  end

  def test_append_mixed_types
    assert_equal "hello123", @context.tfl_APPEND("hello", 1, 2, 3)
  end

  def test_append_with_nil
    assert_equal "helloworld", @context.tfl_APPEND("hello", nil, "world")
  end

  def test_append_with_tfl_null
    assert_equal "helloworld", @context.tfl_APPEND("hello", :tfl_null_value, "world")
  end

  def test_append_empty_args
    assert_equal "", @context.tfl_APPEND()
  end

  def test_append_single_arg
    assert_equal "hello", @context.tfl_APPEND("hello")
  end

  def test_append_all_nulls
    assert_equal "", @context.tfl_APPEND(nil, :tfl_null_value, nil)
  end

  def test_append_with_boolean
    assert_equal "truefalse", @context.tfl_APPEND(true, false)
  end
end
