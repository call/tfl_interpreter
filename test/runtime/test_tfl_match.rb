require_relative '../test_helper'

class TestTflMatch < Minitest::Test
  def setup
    @context = TflTestContext.new
  end

  def test_match_simple_pattern
    assert_equal true, @context.tfl_MATCH("hello", "ell")
  end

  def test_match_regex_pattern
    assert_equal true, @context.tfl_MATCH("hello123", "\\d+")
  end

  def test_match_start_anchor
    assert_equal true, @context.tfl_MATCH("hello", "^he")
    assert_equal false, @context.tfl_MATCH("hello", "^lo")
  end

  def test_match_end_anchor
    assert_equal true, @context.tfl_MATCH("hello", "lo$")
    assert_equal false, @context.tfl_MATCH("hello", "he$")
  end

  def test_match_case_sensitive
    assert_equal false, @context.tfl_MATCH("Hello", "^h")
  end

  def test_match_with_special_characters
    assert_equal true, @context.tfl_MATCH("test@example.com", "@")
  end

  def test_match_no_match
    assert_equal false, @context.tfl_MATCH("hello", "xyz")
  end

  def test_match_with_nil_text
    assert_equal :tfl_null_value, @context.tfl_MATCH(nil, "pattern")
  end

  def test_match_with_tfl_null_text
    assert_equal :tfl_null_value, @context.tfl_MATCH(:tfl_null_value, "pattern")
  end

  def test_match_with_nil_pattern
    assert_equal :tfl_null_value, @context.tfl_MATCH("text", nil)
  end

  def test_match_with_tfl_null_pattern
    assert_equal :tfl_null_value, @context.tfl_MATCH("text", :tfl_null_value)
  end

  def test_match_with_number
    assert_equal true, @context.tfl_MATCH(123, "23")
  end

  def test_match_invalid_regex
    result = @context.tfl_MATCH("text", "[invalid")
    assert_equal :tfl_null_value, result
  end

  def test_match_word_boundary
    assert_equal true, @context.tfl_MATCH("hello world", "\\bhello\\b")
    assert_equal false, @context.tfl_MATCH("helloworld", "\\bhello\\b")
  end

  def test_match_character_class
    assert_equal true, @context.tfl_MATCH("cat", "[cr]at")
    assert_equal false, @context.tfl_MATCH("bat", "[cr]at")
  end
end
