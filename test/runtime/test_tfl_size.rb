require_relative '../test_helper'

class TestTflSize < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_size_of_string
    assert_equal 5, @context.tfl_SIZE("hello")
  end

  def test_size_of_empty_string
    assert_equal 0, @context.tfl_SIZE("")
  end

  def test_size_of_array
    assert_equal 3, @context.tfl_SIZE([1, 2, 3])
  end

  def test_size_of_empty_array
    assert_equal 0, @context.tfl_SIZE([])
  end

  def test_size_of_hash
    assert_equal 2, @context.tfl_SIZE({ "a" => 1, "b" => 2 })
  end

  def test_size_of_empty_hash
    assert_equal 0, @context.tfl_SIZE({})
  end

  def test_size_of_nil
    assert_equal 0, @context.tfl_SIZE(nil)
  end

  def test_size_of_tfl_null
    assert_equal 0, @context.tfl_SIZE(:tfl_null_value)
  end

  def test_size_of_number
    assert_equal 0, @context.tfl_SIZE(123)
  end

  def test_size_of_boolean
    assert_equal 0, @context.tfl_SIZE(true)
    assert_equal 0, @context.tfl_SIZE(false)
  end
end
