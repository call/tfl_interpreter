require_relative '../e2e_test_helper'

class TestE2EStringOperations < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "first_name" => "Alice",
      "last_name" => "Smith",
      "prefix" => "Hello",
      "suffix" => "World"
    })
  end

  def test_append_two_strings
    result = @context.execute_tfl('APPEND("Hello", "World")')
    assert_equal "HelloWorld", result
  end

  def test_append_with_data
    result = @context.execute_tfl('APPEND(first_name, " ", last_name)')
    assert_equal "Alice Smith", result
  end

  def test_append_multiple_values
    result = @context.execute_tfl('APPEND("User: ", first_name, " ", last_name)')
    assert_equal "User: Alice Smith", result
  end

  def test_size_of_string
    result = @context.execute_tfl('SIZE(first_name)')
    assert_equal 5, result
  end

  def test_upcase_and_size
    result = @context.execute_tfl('SIZE(UPCASE(first_name))')
    assert_equal 5, result
  end

  def test_chain_string_operations
    result = @context.execute_tfl('first_name |> UPCASE(%) |> APPEND(%, "!")')
    assert_equal "ALICE!", result
  end
end
