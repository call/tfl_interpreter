require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require_relative '../lib/tfl_to_ruby/runtime/helpers'

# Test helper class that includes TflRuntime for testing
class TflTestContext
  include TflRuntime
end
