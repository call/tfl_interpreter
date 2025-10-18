require_relative '../test_helper'

class TestTflGet < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_get_simple_hash_key
    data = { "name" => "Alice" }
    assert_equal "Alice", @context.tfl_get(data, "name")
  end

  def test_get_nested_hash_keys
    data = { "user" => { "name" => "Bob" } }
    assert_equal "Bob", @context.tfl_get(data, "user", "name")
  end

  def test_get_array_index_with_integer
    data = { "items" => [10, 20, 30] }
    assert_equal 20, @context.tfl_get(data, "items", 1)
  end

  def test_get_array_index_with_string
    data = { "items" => [10, 20, 30] }
    assert_equal 20, @context.tfl_get(data, "items", "1")
  end

  def test_get_missing_key_returns_null
    data = { "name" => "Alice" }
    assert_equal :tfl_null_value, @context.tfl_get(data, "missing")
  end

  def test_get_deeply_nested_missing_key
    data = { "user" => { "name" => "Bob" } }
    assert_equal :tfl_null_value, @context.tfl_get(data, "user", "missing", "deeply")
  end

  def test_get_array_out_of_bounds
    data = { "items" => [10, 20] }
    assert_equal :tfl_null_value, @context.tfl_get(data, "items", 5)
  end

  def test_get_with_nil_data
    assert_equal :tfl_null_value, @context.tfl_get(nil, "key")
  end

  def test_get_with_tfl_null
    assert_equal :tfl_null_value, @context.tfl_get(:tfl_null_value, "key")
  end

  def test_get_invalid_array_access_with_string_key
    data = { "items" => [10, 20, 30] }
    assert_equal :tfl_null_value, @context.tfl_get(data, "items", "invalid")
  end

  def test_get_mixed_hash_and_array_access
    data = { "users" => [{ "name" => "Alice" }, { "name" => "Bob" }] }
    assert_equal "Bob", @context.tfl_get(data, "users", 1, "name")
  end
end
