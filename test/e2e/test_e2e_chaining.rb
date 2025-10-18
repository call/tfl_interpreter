require_relative '../e2e_test_helper'

class TestE2EChaining < Minitest::Test
  def setup
    @context = E2ETestContext.new({
      "email" => "ALICE@EXAMPLE.COM",
      "name" => "  bob  ",
      "url" => "/api/users"
    })
  end

  def test_simple_chain
    result = @context.execute_tfl('email |> DOWNCASE(%)')
    assert_equal "alice@example.com", result
  end

  def test_multiple_chain
    result = @context.execute_tfl('email |> DOWNCASE(%) |> SIZE(%)')
    assert_equal 17, result
  end

  def test_chain_with_default
    result = @context.execute_tfl('missing_field |> DEFAULT(%, "unknown")')
    assert_equal "unknown", result
  end

  def test_chain_with_append
    result = @context.execute_tfl('url |> APPEND(%, "/123")')
    assert_equal "/api/users/123", result
  end

  def test_complex_chain
    result = @context.execute_tfl('email |> DOWNCASE(%) |> DEFAULT(%, "no-email") |> UPCASE(%)')
    assert_equal "ALICE@EXAMPLE.COM", result
  end
end
