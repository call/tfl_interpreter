require_relative '../e2e_test_helper'

class TestE2EComplexExpressions < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "user" => {
        "name" => "Alice",
        "email" => "ALICE@EXAMPLE.COM",
        "age" => 30,
        "tags" => ["admin", "developer", "designer"]
      },
      "metrics" => {
        "scores" => [85, 92, 78, 95]
      },
      "url" => "/api/users"
    })
  end

  def test_complex_conditional_with_nested_access
    result = @context.execute_tfl('IF(user.age > 25, UPCASE(user.name), DOWNCASE(user.name))')
    assert_equal "ALICE", result
  end

  def test_chain_with_nested_data
    result = @context.execute_tfl('user.email |> DOWNCASE(%) |> APPEND("Welcome, ", %)')
    assert_equal "Welcome, alice@example.com", result
  end

  def test_array_operations_chain
    result = @context.execute_tfl('user.tags |> JOIN(%, ", ") |> UPCASE(%)')
    assert_equal "ADMIN, DEVELOPER, DESIGNER", result
  end

  def test_arithmetic_with_array_access
    result = @context.execute_tfl('metrics.scores[0] + metrics.scores[1]')
    assert_equal 177, result
  end

  def test_size_of_nested_array
    result = @context.execute_tfl('SIZE(metrics.scores)')
    assert_equal 4, result
  end

  def test_conditional_with_default
    result = @context.execute_tfl('IF(user.premium, "Premium", DEFAULT(user.type, "Standard"))')
    assert_equal "Standard", result
  end

  def test_url_building
    result = @context.execute_tfl('APPEND(url, "/", user.name)')
    assert_equal "/api/users/Alice", result
  end

  def test_multiple_chains_with_conditionals
    result = @context.execute_tfl('user.email |> DOWNCASE(%) |> IF(SIZE(%) > 10, %, "short")')
    assert_equal "alice@example.com", result
  end

  def test_literal_array_with_data_mixing
    result = @context.execute_tfl('JOIN([user.name, "is", user.age, "years old"], " ")')
    assert_equal "Alice is 30 years old", result
  end

  def test_nested_function_calls
    result = @context.execute_tfl('SIZE(JOIN(user.tags, "-"))')
    assert_equal 24, result # "admin-developer-designer"
  end
end
