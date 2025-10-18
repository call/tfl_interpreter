require_relative '../e2e_test_helper'

class TestE2ENestedAccess < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "user" => {
        "profile" => {
          "name" => "Alice",
          "email" => "alice@example.com"
        },
        "settings" => {
          "theme" => "dark"
        }
      },
      "users" => [
        { "name" => "Bob", "age" => 25 },
        { "name" => "Charlie", "age" => 30 }
      ]
    })
  end

  def test_nested_object_access
    result = @context.execute_tfl('user.profile.name')
    assert_equal "Alice", result
  end

  def test_deeply_nested_access
    result = @context.execute_tfl('user.settings.theme')
    assert_equal "dark", result
  end

  def test_array_of_objects
    result = @context.execute_tfl('users[0].name')
    assert_equal "Bob", result
  end

  def test_array_of_objects_second_element
    result = @context.execute_tfl('users[1].age')
    assert_equal 30, result
  end

  def test_missing_nested_key
    result = @context.execute_tfl('user.profile.missing')
    assert_equal :tfl_null_value, result
  end

  def test_missing_nested_key_with_default
    result = @context.execute_tfl('DEFAULT(user.profile.missing, "N/A")')
    assert_equal "N/A", result
  end
end
