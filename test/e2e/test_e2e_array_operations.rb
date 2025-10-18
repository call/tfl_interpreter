require_relative '../e2e_test_helper'

class TestE2EArrayOperations < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "items" => [10, 20, 30, 40, 50],
      "names" => ["Alice", "Bob", "Charlie"],
      "empty" => []
    })
  end

  def test_array_access
    result = @context.execute_tfl('items[0]')
    assert_equal 10, result
  end

  def test_array_access_last_element
    result = @context.execute_tfl('items[4]')
    assert_equal 50, result
  end

  def test_array_size
    result = @context.execute_tfl('SIZE(items)')
    assert_equal 5, result
  end

  def test_empty_array_size
    result = @context.execute_tfl('SIZE(empty)')
    assert_equal 0, result
  end

  def test_array_join_default_separator
    result = @context.execute_tfl('JOIN(names)')
    assert_equal "Alice Bob Charlie", result
  end

  def test_array_join_custom_separator
    result = @context.execute_tfl('JOIN(names, ", ")')
    assert_equal "Alice, Bob, Charlie", result
  end

  def test_literal_array
    result = @context.execute_tfl('[1, 2, 3]')
    assert_equal [1, 2, 3], result
  end

  def test_literal_array_size
    result = @context.execute_tfl('SIZE([1, 2, 3, 4, 5])')
    assert_equal 5, result
  end

  def test_literal_array_join
    result = @context.execute_tfl('JOIN([1, 2, 3], "-")')
    assert_equal "1-2-3", result
  end

  def test_nested_array_join
    result = @context.execute_tfl('JOIN([JOIN([1, 2]), 3, 4], "-")')
    assert_equal "1 2-3-4", result
  end
end
