require_relative '../e2e_test_helper'

class TestE2EEdgeCases < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "null_field" => nil,
      "empty_string" => "",
      "zero" => 0,
      "false_value" => false,
      "empty_array" => [],
      "empty_hash" => {}
    })
  end

  def test_null_with_default
    result = @context.execute_tfl('DEFAULT(null_field, "fallback")')
    assert_equal "fallback", result
  end

  def test_empty_string_not_null
    result = @context.execute_tfl('DEFAULT(empty_string, "fallback")')
    assert_equal "", result
  end

  def test_zero_not_null
    result = @context.execute_tfl('DEFAULT(zero, 99)')
    assert_equal 0, result
  end

  def test_false_not_null
    result = @context.execute_tfl('DEFAULT(false_value, true)')
    assert_equal false, result
  end

  def test_if_with_zero_is_truthy
    result = @context.execute_tfl('IF(zero, "yes", "no")')
    assert_equal "yes", result
  end

  def test_if_with_false_is_falsy
    result = @context.execute_tfl('IF(false_value, "yes", "no")')
    assert_equal "no", result
  end

  def test_size_of_empty_array
    result = @context.execute_tfl('SIZE(empty_array)')
    assert_equal 0, result
  end

  def test_size_of_empty_hash
    result = @context.execute_tfl('SIZE(empty_hash)')
    assert_equal 0, result
  end

  def test_join_empty_array
    result = @context.execute_tfl('JOIN(empty_array, ",")')
    assert_equal "", result
  end

  def test_append_with_null
    result = @context.execute_tfl('APPEND("hello", null_field, "world")')
    assert_equal "helloworld", result
  end

  def test_parentheses_precedence
    result = @context.execute_tfl('(5 + 3) * 2')
    assert_equal 16, result
  end

  def test_operator_precedence
    result = @context.execute_tfl('5 + 3 * 2')
    assert_equal 11, result
  end
end
