require_relative 'test_helper'

# Require all test files
Dir[File.join(__dir__, 'runtime', 'test_*.rb')].each { |file| require file }
