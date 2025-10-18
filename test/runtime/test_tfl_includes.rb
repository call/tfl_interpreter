require_relative '../test_helper'

class TestTflIncludes < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_includes_string_in_array
    assert_equal true, @context.tfl_INCLUDES(["apple", "banana", "cherry"], "banana")
  end

  def test_includes_number_in_array
    assert_equal true, @context.tfl_INCLUDES([1, 2, 3, 4, 5], 3)
  end

  def test_includes_not_found
    assert_equal false, @context.tfl_INCLUDES(["apple", "banana"], "orange")
  end

  def test_includes_empty_array
    assert_equal false, @context.tfl_INCLUDES([], "anything")
  end

  def test_includes_nil_value
    assert_equal true, @context.tfl_INCLUDES([1, nil, 3], nil)
  end

  def test_includes_boolean_true
    assert_equal true, @context.tfl_INCLUDES([true, false], true)
  end

  def test_includes_boolean_false
    assert_equal true, @context.tfl_INCLUDES([true, false], false)
  end

  def test_includes_with_nil_array
    assert_equal :tfl_null_value, @context.tfl_INCLUDES(nil, "value")
  end

  def test_includes_with_tfl_null_array
    assert_equal :tfl_null_value, @context.tfl_INCLUDES(:tfl_null_value, "value")
  end

  def test_includes_with_non_array
    assert_equal false, @context.tfl_INCLUDES("not an array", "value")
  end

  def test_includes_mixed_types
    assert_equal true, @context.tfl_INCLUDES([1, "two", 3.0, true], "two")
  end

  def test_includes_nested_array
    nested = [[1, 2], [3, 4]]
    assert_equal true, @context.tfl_INCLUDES(nested, [1, 2])
  end

  def test_includes_hash_in_array
    hashes = [{ "a" => 1 }, { "b" => 2 }]
    assert_equal true, @context.tfl_INCLUDES(hashes, { "a" => 1 })
  end

  def test_includes_case_sensitive
    assert_equal false, @context.tfl_INCLUDES(["Apple", "Banana"], "apple")
  end
end
