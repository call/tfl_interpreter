require_relative '../test_helper'

class TestTflLambdaAndFilterIntegration < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_filter_with_match_example_from_docs
    # Example 1 from documentation
    my_array = ["red", "blue", "green"]
    lambda_func = @context.tfl_LAMBDA(:element) { |element|
      @context.tfl_MATCH(element, "r")
    }
    result = @context.tfl_FILTER(my_array, lambda_func)
    assert_equal ["red", "green"], result
  end

  def test_filter_array_difference_example_from_docs
    # Example 2 from documentation
    array_one = ["dog", "cat", "turtle", "dinosaur", "lizard", "chicken", "koala"]
    array_two = ["cat", "elephant", "giraffe", "penguin", "tiger", "koala"]

    lambda_func = @context.tfl_LAMBDA(:array_two_elem) { |array_two_elem|
      @context.tfl_NOT(@context.tfl_INCLUDES(array_one, array_two_elem))
    }

    result = @context.tfl_FILTER(array_two, lambda_func)
    assert_equal ["elephant", "giraffe", "penguin", "tiger"], result
  end

  def test_chained_filters
    # Filter numbers > 5, then filter even numbers
    lambda_func1 = @context.tfl_LAMBDA(:x) { |x| x > 5 }
    lambda_func2 = @context.tfl_LAMBDA(:x) { |x| x % 2 == 0 }

    result = @context.tfl_FILTER([1, 6, 3, 8, 2, 10, 7], lambda_func1)
    result = @context.tfl_FILTER(result, lambda_func2)

    assert_equal [6, 8, 10], result
  end

  def test_filter_with_string_operations
    # Filter strings, uppercase them, and check length
    lambda_func = @context.tfl_LAMBDA(:s) { |s|
      @context.tfl_SIZE(@context.tfl_UPCASE(s)) > 3
    }
    result = @context.tfl_FILTER(["hi", "hello", "bye"], lambda_func)
    assert_equal ["hello"], result
  end

  def test_filter_nested_data_structures
    data = [
      { "name" => "Alice", "age" => 30 },
      { "name" => "Bob", "age" => 25 },
      { "name" => "Charlie", "age" => 35 }
    ]

    lambda_func = @context.tfl_LAMBDA(:person) { |person|
      person["age"] > 28
    }

    result = @context.tfl_FILTER(data, lambda_func)
    assert_equal 2, result.length
    assert_equal "Alice", result[0]["name"]
    assert_equal "Charlie", result[1]["name"]
  end
end
