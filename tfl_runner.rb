# tfl_runner.rb
#
# Phase 6: Orchestration and Demonstration
# This script loads the interpreter and runs several TFL expressions against
# mock data to show the final, executable Ruby output.

require 'json'
require_relative 'lib/tfl_interpreter/interpreter'
require_relative 'lib/tfl_interpreter/runtime/helpers'

# --- 1. Setup ---

# Instantiate the main interpreter engine
interpreter = TflInterpreter::Interpreter.new

# Mock data structure, equivalent to a Tines event payload
MOCK_DATA = {
  "user_action" => {
    "name" => "Alice",
    "status" => "active",
    "email" => "ALICE@EXAMPLE.COM"
  },
  "data_array" => [10, 20, 30],
  "date_string" => "2024-06-15T12:34:56Z",
  "message" => nil,
  "nested" => {
    "key" => "value"
  }
}.freeze

# A class to provide the execution context for the generated Ruby code.
# It includes the TflRuntime module so the generated code can access helpers
# like 'tfl_get', 'tfl_JOIN', and the TFL_NULL constant.
class TflRunnerContext
  include TflRuntime
  attr_reader :data

  def initialize(data)
    @data = data
  end

  # Executes the generated Ruby code string within this context.
  def run_tfl(ruby_code)
    # The generated code expects a local variable named 'data_context'
    # which is assigned from the @data instance variable.
    eval(ruby_code)
  end
end


# --- 2. Test Cases ---

TFL_TEST_CASES = {
  # # Simple Function Call (will use built-in Ruby method after transpilation)
  # "Simple Function Call" => 'UPCASE("hello")',

  # # Data Access (requires the safe tfl_get helper)
  # "Safe Data Access" => 'user_action.name',

  # # Handling missing data (should return TFL_NULL)
  # "Missing Data Check" => 'missing_action.property',

  # # Binary Operation (requires parenthesis and type checking)
  # "Binary Logic" => 'user_action.status = "active"',

  # # Conditional Logic (requires tfl_IF helper)
  # "Conditional IF" => 'IF(data_array[0] > 5, "Large Array", "Small Array")',

  # # Function Chaining (requires sequential assignments via Interpreter)
  # "Function Chaining" => 'user_action.email |> DOWNCASE(%) |> DEFAULT(%, "unknown")',

  # # Nested function calls (demonstrates recursive AST traversal)
  # "Nested Call" => 'SIZE(data_array)',

  # # Parse a date
  # "Date Parsing" => 'DATE("twenty-four days ago", "%Y-%m-%d")',

  # # JOIN function
  # "Join Array" => 'JOIN([1,2,3,4,5]), "-")',

  # # Size
  # "Size" => 'SIZE(DATE("three days ago", "%s"))',

  # #Literal Array
  # "SizeLiteralArray" => 'SIZE([1,2,3,4,5,6])',

  # "APPEND Simple" => 'APPEND("app", "end", "ing")',
  # "APPEND With Data" => 'APPEND(user_action.name, " is ", user_action.status)',
  # "APPEND With Null" => 'APPEND("hello", missing_action.property, "world")',

  # "test" => "JOIN([JOIN([12,23]),3,4,5])"
  "DATE" => 'DATE("01/02/2023")'
}.freeze


# --- 3. Execution ---

puts "--- TFL Interpreter Demo ---"
puts "Mock Input Data: #{MOCK_DATA.to_json}"
puts "---------------------------\n\n"

context = TflRunnerContext.new(MOCK_DATA)

result = context.tfl_DATE("01/02/2023", "%Y-%m-%d")
puts(context)

TFL_TEST_CASES.each do |title, tfl_expression|
  puts "TFL Expression: #{tfl_expression}"

  # 1. Transpile the TFL expression to Ruby
  ruby_code = interpreter.transpile(tfl_expression, data_context_name: 'data_context')

  puts "\n  -> Generated Ruby Code:"
  # Print the generated code without the boilerplate comments for brevity
  puts ruby_code.split("\n")[4..-2].map { |line| "     #{line}" }.join("\n")

  # 2. Execute the generated Ruby code within the context
  begin
    result = context.run_tfl(ruby_code)

    # 3. Display the result
    puts "\n  -> Execution Result: #{result.is_a?(String) ? "\"#{result}\"" : result}"
    puts "--------------------------------------------------------------------------------"
  rescue StandardError => e
    puts "\n  -> !!! ERROR DURING EXECUTION: #{e.message}"
    puts "--------------------------------------------------------------------------------"
  end
end
