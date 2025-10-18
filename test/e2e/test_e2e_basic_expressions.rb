require_relative '../e2e_test_helper'

class TestE2EBasicExpressions < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "name" => "Alice",
      "age" => 30,
      "email" => "ALICE@EXAMPLE.COM",
      "status" => "active"
    })
  end

  def test_simple_data_access
    result = @context.execute_tfl('name')
    assert_equal "Alice", result
  end

  def test_simple_function_call
    result = @context.execute_tfl('UPCASE("hello")')
    assert_equal "HELLO", result
  end

  def test_function_with_data_reference
    result = @context.execute_tfl('UPCASE(email)')
    assert_equal "ALICE@EXAMPLE.COM", result
  end

  def test_downcase_with_data_reference
    result = @context.execute_tfl('DOWNCASE(email)')
    assert_equal "alice@example.com", result
  end

  def test_binary_operation_equality
    result = @context.execute_tfl('status = "active"')
    assert_equal true, result
  end

  def test_binary_operation_inequality
    result = @context.execute_tfl('status = "inactive"')
    assert_equal false, result
  end

  def test_binary_operation_greater_than
    result = @context.execute_tfl('age > 25')
    assert_equal true, result
  end

  def test_binary_operation_less_than
    result = @context.execute_tfl('age < 25')
    assert_equal false, result
  end

  def test_arithmetic_addition
    result = @context.execute_tfl('age + 10')
    assert_equal 40, result
  end

  def test_arithmetic_multiplication
    result = @context.execute_tfl('age * 2')
    assert_equal 60, result
  end
end
