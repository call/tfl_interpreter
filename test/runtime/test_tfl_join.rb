require_relative '../test_helper'

class TestTflJoin < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_join_array_with_default_separator
    assert_equal "1 2 3", @context.tfl_JOIN([1, 2, 3])
  end

  def test_join_array_with_custom_separator
    assert_equal "1-2-3", @context.tfl_JOIN([1, 2, 3], "-")
  end

  def test_join_string_array
    assert_equal "a,b,c", @context.tfl_JOIN(["a", "b", "c"], ",")
  end

  def test_join_mixed_types
    assert_equal "1,hello,true", @context.tfl_JOIN([1, "hello", true], ",")
  end

  def test_join_with_nil_elements
    assert_equal "a,,c", @context.tfl_JOIN(["a", nil, "c"], ",")
  end

  def test_join_with_tfl_null_elements
    assert_equal "a,,c", @context.tfl_JOIN(["a", :tfl_null_value, "c"], ",")
  end

  def test_join_empty_array
    assert_equal "", @context.tfl_JOIN([], ",")
  end

  def test_join_single_element
    assert_equal "hello", @context.tfl_JOIN(["hello"], ",")
  end

  def test_join_with_nil_array
    assert_equal :tfl_null_value, @context.tfl_JOIN(nil, ",")
  end

  def test_join_with_tfl_null_array
    assert_equal :tfl_null_value, @context.tfl_JOIN(:tfl_null_value, ",")
  end

  def test_join_non_array
    assert_equal :tfl_null_value, @context.tfl_JOIN("not an array", ",")
  end

  def test_join_with_number_separator
    assert_equal "a0b0c", @context.tfl_JOIN(["a", "b", "c"], 0)
  end
end
