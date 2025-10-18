#!/usr/bin/env ruby
# test_complex_tfl.rb
#
# Demonstrates complex TFL expressions using multiple runtime helpers

require 'json'
require_relative 'lib/tfl_interpreter/interpreter'
require_relative 'lib/tfl_interpreter/runtime/helpers'

# Execution context for generated Ruby code
class TflTestContext
  include TflRuntime
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def run_tfl(ruby_code)
    eval(ruby_code)
  end
end

# --- Mock Data ---
MOCK_DATA = {
  "user" => {
    "name" => "Alice Johnson",
    "email" => "ALICE@EXAMPLE.COM",
    "age" => 28,
    "score" => -15.5,
    "tags" => ["ruby", "python", "javascript"]
  },
  "transactions" => [
    { "amount" => -150, "date" => "2024-01-15" },
    { "amount" => 200, "date" => "2024-02-20" },
    { "amount" => -75.50, "date" => "2024-03-10" }
  ],
  "metadata" => {
    "created_at" => "2024-06-15T12:34:56Z",
    "status" => "active"
  }
}.freeze

# --- Complex TFL Test Cases ---
COMPLEX_TESTS = {
  "User Profile Summary" =>
    'APPEND(user.name, " (", DOWNCASE(user.email), ") - Age: ", user.age)',

  "Absolute Score with Default" =>
    'DEFAULT(ABS(user.score), 0)',

  "Tag List Formatter" =>
    'APPEND("Skills: ", UPCASE(JOIN(user.tags, ", ")))',

  "Conditional Message with ABS" =>
    'IF(ABS(user.score) > 10, APPEND("High score: ", ABS(user.score)), "Low score")',

  "Transaction Count Check" =>
    'IF(SIZE(transactions) > 0, APPEND("You have ", SIZE(transactions), " transactions"), "No transactions")',

  "Nested Data Access with Formatting" =>
    'APPEND("Status: ", UPCASE(metadata.status), " | Created: ", DATE(metadata.created_at, "%B %d, %Y"))',

  "Complex Conditional with Multiple Functions" =>
    'IF(SIZE(user.tags) > 2, APPEND(user.name, " knows ", SIZE(user.tags), " languages!"), DEFAULT(user.name, "Unknown"))',

  "Absolute Values with Array Size" =>
    'APPEND("Score magnitude: ", ABS(user.score), " | Tag count: ", SIZE(user.tags))',

  "Multi-level Data Access" =>
    'APPEND(UPCASE(user.name), " - ", JOIN(user.tags, " & "), " - ", SIZE(transactions), " txns")',

  "Date Formatting with Conditionals" =>
    'IF(metadata.status = "active", DATE(metadata.created_at, "%Y-%m-%d %H:%M"), "Inactive")',

  "Chained String Operations" =>
    'UPCASE(APPEND("Hello ", user.name, "!"))',

  "Array Size Comparison" =>
    'IF(SIZE(user.tags) > SIZE(transactions), "More tags than transactions", "More transactions than tags")',

  "Missing Data with Defaults and ABS" =>
    'ABS(DEFAULT(user.balance, -100))',

  "Complex NOT Logic" =>
    'IF(NOT(user.score > 0), APPEND("Negative score: ", ABS(user.score)), "Positive score")',

  "Nested IF with Multiple Functions" =>
    'IF(SIZE(user.tags) > 0, IF(ABS(user.score) > 10, "Skilled and high scoring", "Skilled but low score"), "No skills listed")'
}.freeze

# --- Execution ---
def run_tests
  interpreter = TflInterpreter::Interpreter.new
  context = TflTestContext.new(MOCK_DATA)

  puts "=" * 80
  puts "COMPLEX TFL EXPRESSION TESTS"
  puts "=" * 80
  puts "\nMock Data:"
  puts JSON.pretty_generate(MOCK_DATA)
  puts "\n" + "=" * 80 + "\n\n"

  COMPLEX_TESTS.each_with_index do |(title, tfl_expr), index|
    puts "Test #{index + 1}: #{title}"
    puts "-" * 80
    puts "TFL Expression:"
    puts "  #{tfl_expr}"
    puts

    begin
      # Transpile TFL to Ruby
      ruby_code = interpreter.transpile(tfl_expr, data_context_name: 'data_context')

      # Show generated Ruby (without boilerplate comments)
      ruby_lines = ruby_code.split("\n")[4..-2]
      puts "Generated Ruby:"
      ruby_lines.each { |line| puts "  #{line}" }
      puts

      # Execute
      result = context.run_tfl(ruby_code)

      # Display result
      puts "Result:"
      if result == TflRuntime::TFL_NULL
        puts "  TFL_NULL"
      elsif result.is_a?(String)
        puts "  \"#{result}\""
      else
        puts "  #{result} (#{result.class})"
      end

    rescue StandardError => e
      puts "ERROR: #{e.message}"
      puts e.backtrace.first(3).map { |line| "  #{line}" }.join("\n")
    end

    puts "\n" + "=" * 80 + "\n\n"
  end
end

# Run the tests
if __FILE__ == $0
  run_tests
end
