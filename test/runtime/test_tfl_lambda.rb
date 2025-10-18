require_relative '../test_helper'

class TestTflLambda < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_lambda_simple_addition
    lambda_func = @context.tfl_LAMBDA(:x, :y) { |x, y| x + y }
    assert_equal 5, lambda_func.call(2, 3)
  end

  def test_lambda_single_parameter
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x * 2 }
    assert_equal 10, lambda_func.call(5)
  end

  def test_lambda_string_concatenation
    lambda_func = @context.tfl_LAMBDA(:a, :b) { |a, b| "#{a} #{b}" }
    assert_equal "hello world", lambda_func.call("hello", "world")
  end

  def test_lambda_with_comparison
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x > 10 }
    assert_equal true, lambda_func.call(15)
    assert_equal false, lambda_func.call(5)
  end

  def test_lambda_wrong_number_of_arguments
    lambda_func = @context.tfl_LAMBDA(:x, :y) { |x, y| x + y }
    assert_equal :tfl_null_value, lambda_func.call(1) # Too few args
    assert_equal :tfl_null_value, lambda_func.call(1, 2, 3) # Too many args
  end

  def test_lambda_no_block
    result = @context.tfl_LAMBDA(:x, :y)
    assert_equal :tfl_null_value, result
  end

  def test_lambda_with_error
    lambda_func = @context.tfl_LAMBDA(:x) { |x| x / 0 }
    assert_equal :tfl_null_value, lambda_func.call(10)
  end

  def test_lambda_returning_nil
    lambda_func = @context.tfl_LAMBDA(:x) { |x| nil }
    assert_nil lambda_func.call(5)
  end

  def test_lambda_complex_expression
    lambda_func = @context.tfl_LAMBDA(:x, :y, :z) { |x, y, z| (x + y) * z }
    assert_equal 15, lambda_func.call(2, 3, 3)
  end
end
