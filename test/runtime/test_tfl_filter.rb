require_relative '../test_helper'

class TestTflFilter < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_filter_simple_condition
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x > 5 }
    result = @context.tfl_FILTER([1, 6, 3, 8, 2, 10], lambda_func)
    assert_equal [6, 8, 10], result
  end

  def test_filter_string_match
    lambda_func = @context.tfl_LAMBDA(:element) { |element| @context.tfl_MATCH(element, "r") }
    result = @context.tfl_FILTER(["red", "blue", "green"], lambda_func)
    assert_equal ["red", "green"], result
  end

  def test_filter_with_includes
    array_one = ["dog", "cat", "turtle"]
    lambda_func = @context.tfl_LAMBDA(:elem) { |elem|
      @context.tfl_NOT(@context.tfl_INCLUDES(array_one, elem))
    }
    result = @context.tfl_FILTER(["cat", "elephant", "giraffe"], lambda_func)
    assert_equal ["elephant", "giraffe"], result
  end

  def test_filter_all_pass
    lambda_func = @context.tfl_LAMBDA(:x) { |x| true }
    result = @context.tfl_FILTER([1, 2, 3], lambda_func)
    assert_equal [1, 2, 3], result
  end

  def test_filter_none_pass
    lambda_func = @context.tfl_LAMBDA(:x) { |x| false }
    result = @context.tfl_FILTER([1, 2, 3], lambda_func)
    assert_equal [], result
  end

  def test_filter_empty_array
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x > 5 }
    result = @context.tfl_FILTER([], lambda_func)
    assert_equal [], result
  end

  def test_filter_with_nil_array
    lambda_func = @context.tfl_LAMBDA(:x) { |x| true }
    assert_equal :tfl_null_value, @context.tfl_FILTER(nil, lambda_func)
  end

  def test_filter_with_tfl_null_array
    lambda_func = @context.tfl_LAMBDA(:x) { |x| true }
    assert_equal :tfl_null_value, @context.tfl_FILTER(:tfl_null_value, lambda_func)
  end

  def test_filter_with_nil_lambda
    assert_equal :tfl_null_value, @context.tfl_FILTER([1, 2, 3], nil)
  end

  def test_filter_with_non_array
    lambda_func = @context.tfl_LAMBDA(:x) { |x| true }
    assert_equal :tfl_null_value, @context.tfl_FILTER("not array", lambda_func)
  end

  def test_filter_lambda_returns_tfl_null
    lambda_func = @context.tfl_LAMBDA(:x) { |x| :tfl_null_value }
    result = @context.tfl_FILTER([1, 2, 3], lambda_func)
    assert_equal [], result
  end

  def test_filter_lambda_with_error
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x / 0 }
    result = @context.tfl_FILTER([1, 2, 3], lambda_func)
    assert_equal [], result # All elements skipped due to error
  end

  def test_filter_even_numbers
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x % 2 == 0 }
    result = @context.tfl_FILTER([1, 2, 3, 4, 5, 6], lambda_func)
    assert_equal [2, 4, 6], result
  end

  def test_filter_strings_longer_than_3
    lambda_func = @context.tfl_LAMBDA(:s) { |s| s.length > 3 }
    result = @context.tfl_FILTER(["hi", "hello", "bye", "world"], lambda_func)
    assert_equal ["hello", "world"], result
  end

  def test_filter_with_zero_returns_truthy
    # Zero should be truthy in TFL
    lambda_func = @context.tfl_LAMBDA(:x) { |x| 0 }
    result = @context.tfl_FILTER([1, 2, 3], lambda_func)
    assert_equal [1, 2, 3], result
  end

  def test_filter_complex_condition
    # Filter elements where element * 2 > 10
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x * 2 > 10 }
    result = @context.tfl_FILTER([3, 5, 6, 7, 2], lambda_func)
    assert_equal [6, 7], result
  end
end
