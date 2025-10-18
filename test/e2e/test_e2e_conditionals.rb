require_relative '../e2e_test_helper'

class TestE2EConditionals < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "age" => 30,
      "status" => "active",
      "score" => 85,
      "empty_field" => nil
    })
  end

  def test_if_true_condition
    result = @context.execute_tfl('IF(age > 25, "adult", "young")')
    assert_equal "adult", result
  end

  def test_if_false_condition
    result = @context.execute_tfl('IF(age < 25, "young", "adult")')
    assert_equal "adult", result
  end

  def test_if_with_equality
    result = @context.execute_tfl('IF(status = "active", "Active User", "Inactive User")')
    assert_equal "Active User", result
  end

  def test_if_without_else
    result = @context.execute_tfl('IF(age > 18, "Can vote")')
    assert_equal "Can vote", result
  end

  def test_if_without_else_false
    result = @context.execute_tfl('IF(age < 18, "Minor")')
    assert_equal :tfl_null_value, result
  end

  def test_nested_if
    result = @context.execute_tfl('IF(age > 18, IF(score > 80, "Pass", "Fail"), "Too young")')
    assert_equal "Pass", result
  end

  def test_if_with_null_check
    result = @context.execute_tfl('IF(empty_field, "Has value", "No value")')
    assert_equal "No value", result
  end
end
