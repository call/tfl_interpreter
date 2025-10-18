require_relative 'e2e_test_helper'

# Require all E2E test files
Dir[File.join(__dir__, 'e2e', 'test_*.rb')].each { |file| require file }
