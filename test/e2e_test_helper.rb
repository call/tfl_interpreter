require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require_relative '../lib/tfl_interpreter/interpreter'
require_relative '../lib/tfl_interpreter/runtime/helpers'

# Test context that executes transpiled TFL code
class E2ETestContext
  include TflRuntime
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def execute_tfl(tfl_expression)
    interpreter = TflInterpreter::Interpreter.new
    ruby_code = interpreter.transpile(tfl_expression, data_context_name: 'data_context')
    eval(ruby_code)
  end
end
