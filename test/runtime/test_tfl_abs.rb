require_relative '../test_helper'

class TestAbs < Minitest::Test
  include TflRuntime

  def test_abs_with_negative_integer
    assert_equal 17, tfl_ABS(-17)
  end

  def test_abs_with_positive_integer
    assert_equal 4, tfl_ABS(4)
  end

  def test_abs_with_negative_float
    assert_equal 19.86, tfl_ABS(-19.86)
  end

  def test_abs_with_positive_float
    assert_equal 3.14, tfl_ABS(3.14)
  end

  def test_abs_with_zero
    assert_equal 0, tfl_ABS(0)
  end

  def test_abs_with_negative_string
    assert_equal 19.86, tfl_ABS("-19.86")
  end

  def test_abs_with_positive_string
    assert_equal 42, tfl_ABS("42")
  end

  def test_abs_with_negative_integer_string
    assert_equal 17, tfl_ABS("-17")
  end

  def test_abs_with_whole_number_float
    # Should return integer when result is a whole number
    assert_equal 5, tfl_ABS(-5.0)
    assert_instance_of Integer, tfl_ABS(-5.0)
  end

  def test_abs_with_whole_number_string
    assert_equal 10, tfl_ABS("10.0")
    assert_instance_of Integer, tfl_ABS("10.0")
  end

  def test_abs_with_nil
    assert_equal TFL_NULL, tfl_ABS(nil)
  end

  def test_abs_with_tfl_null
    assert_equal TFL_NULL, tfl_ABS(TFL_NULL)
  end

  def test_abs_with_non_numeric_string
    assert_equal TFL_NULL, tfl_ABS("not a number")
  end

  def test_abs_with_boolean
    assert_equal TFL_NULL, tfl_ABS(true)
    assert_equal TFL_NULL, tfl_ABS(false)
  end

  def test_abs_with_array
    assert_equal TFL_NULL, tfl_ABS([1, 2, 3])
  end

  def test_abs_with_hash
    assert_equal TFL_NULL, tfl_ABS({ key: "value" })
  end
end
