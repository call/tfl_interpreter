# lib/tfl_interpreter/runtime/helpers.rb
#
# Phase 4.1: TFL Runtime Environment
# This module provides the safe utility methods necessary to emulate Tines'
# non-strict, error-tolerant function behavior in Ruby.

module TflRuntime
  # TFL's equivalent of null/undefined. This constant is used internally
  # so that we can distinguish between a Ruby 'nil' and an explicitly returned NULL.
  TFL_NULL = :tfl_null_value

  # --- CORE UTILITY FUNCTIONS ---

  # TFL's safe data access method. It handles array indexes and object keys,
  # returning TFL_NULL instead of raising exceptions if a key is missing.
  # This is used by the DataReference AST node.
  #
  # Example: tfl_get(data_context, "user_action", "name")
  def tfl_get(data, *segments)
    current = data
    segments.each do |segment|
      return TFL_NULL if current.nil? || current == TFL_NULL

      if current.is_a?(Hash)
        # Handle object key access
        current = current.fetch(segment.to_s, TFL_NULL)
      elsif current.is_a?(Array)
        index = nil
        is_numeric_string = segment.is_a?(String) && segment.match?(/^\d+$/)

        if is_numeric_string
          # Handle string segment like "0", "1"
          index = segment.to_i
        elsif segment.is_a?(Integer)
          # Handle integer segment like 0, 1 (if emitted by parser)
          index = segment
        else
          # Segment is not a string representation of a number or an Integer
          return TFL_NULL
        end

        current = current[index]
        current = TFL_NULL if current.nil? # Explicitly return TFL_NULL if index is out of bounds
      else
        # If the segment is invalid for the current object type, stop and return NULL
        return TFL_NULL
      end
    end
    current.nil? ? TFL_NULL : current
  end

  # --- TFL FUNCTION IMPLEMENTATIONS ---

  # ...existing code...

  # APPEND: Joins two or more pieces of text together.
  # Converts all arguments to strings and concatenates them.
  def tfl_APPEND(*args)
    # If no arguments provided, return empty string
    return "" if args.empty?

    # Convert each argument to string, handling nil/TFL_NULL
    args.map do |arg|
      if arg.nil? || arg == TFL_NULL
        ""
      else
        arg.to_s
      end
    end.join
  end

  # SIZE: Returns the size of an array/collection or the length of a string.
  # Returns 0 if the value is TFL_NULL or has no defined size.
  def tfl_SIZE(value)
    # TFL is non-strict: treat nil or TFL_NULL as having size 0.
    return 0 if value.nil? || value == TFL_NULL

    if value.is_a?(String)
      return value.length
    elsif value.respond_to?(:length)
      # Catches Arrays and Hashes
      return value.length
    end

    # For numbers, booleans, or other non-collection/non-string types, size is 0.
    return 0
  end

  # IF: Translates the TFL IF function into a Ruby ternary expression.
  # TFL only considers FALSE and TFL_NULL as falsy. Everything else is truthy.
  def tfl_IF(condition, value_if_true, value_if_false = TFL_NULL)
    if condition == false || condition == TFL_NULL
      return value_if_false
    else
      return value_if_true
    end
  end

  # UPCASE: Converts text to uppercase. Used by one of the test cases.
  def tfl_UPCASE(value)
    return TFL_NULL if value.nil? || value == TFL_NULL
    value.to_s.upcase
  end

  # DOWNCASE: Converts text to lowercase. Used by one of the test cases.
  def tfl_DOWNCASE(value)
    return TFL_NULL if value.nil? || value == TFL_NULL
    value.to_s.downcase
  end

  # DEFAULT: Returns the value if it is present (not TFL_NULL), otherwise returns the fallback.
  def tfl_DEFAULT(value, fallback)
    return fallback if value.nil? || value == TFL_NULL
    value
  end

  # JOIN: Combines elements of an array into a single text value using a separator.
  # Returns TFL_NULL for non-array inputs. Handles conversion of array elements to strings.
  def tfl_JOIN(array, separator = " ")
    return TFL_NULL if array.nil? || array == TFL_NULL

    # If array isn't actually an array, return TFL_NULL
    return TFL_NULL unless array.is_a?(Array)

    # Convert separator to string if it's not already
    separator = separator.to_s

    # Convert each element to string, handling nil/TFL_NULL
    elements = array.map do |elem|
      if elem.nil? || elem == TFL_NULL
        ""
      else
        elem.to_s
      end
    end

    # Join the elements
    elements.join(separator)
  end

  # DATE: Takes a date (string, integer, or DATE_PARSE object) and returns a formatted string.
  # Uses strftime syntax for formatting and tz database timezone names.
  # Natural language parsing via chronic with EU date format as default for ambiguous dates.
  def tfl_DATE(date, format = nil, timezone = "UTC")
    return TFL_NULL if date.nil? || date == TFL_NULL

    require 'chronic'
    require 'tzinfo'

    # Parse the date into a Time object
    time_obj = nil

    if date.is_a?(Integer)
      # Treat as Unix timestamp
      time_obj = Time.at(date)
    elsif date.is_a?(String)
      # Use chronic for natural language parsing
      # Set endian_precedence to :little for EU format (DD/MM/YYYY)
      time_obj = Chronic.parse(date, endian_precedence: :little)
    elsif date.is_a?(Time)
      time_obj = date
    elsif date.is_a?(Hash) && date[:parsed_time]
      # DATE_PARSE object (assuming it returns a hash with :parsed_time key)
      time_obj = date[:parsed_time]
    end

    return TFL_NULL if time_obj.nil?

    # Convert to specified timezone if provided
    if timezone && !timezone.empty?
      begin
        tz = TZInfo::Timezone.get(timezone)
        time_obj = tz.to_local(time_obj.utc)
      rescue TZInfo::InvalidTimezoneIdentifier
        # Invalid timezone, return TFL_NULL or keep original time
        return TFL_NULL
      end
    end

    # Apply format if provided, otherwise return ISO8601
    if format && !format.empty?
      return time_obj.strftime(format)
    else
      return time_obj.iso8601
    end
  rescue => e
    # If any error occurs during parsing or formatting, return TFL_NULL
    TFL_NULL
  end

    # ...existing code...

  # LAMBDA: Creates a custom, reusable function.
  # The last argument is a block (Proc) that represents the calculation.
  # All previous arguments are parameter names (as symbols or strings).
  # Returns a Proc that can be called with arguments matching the parameters.
  #
  # In Ruby, this is implemented by accepting a block and returning it wrapped
  # with parameter binding logic.
  #
  # Example: tfl_LAMBDA(:x, :y) { |x, y| x + y }
  def tfl_LAMBDA(*param_names, &block)
    return TFL_NULL unless block_given?

    # Return a Proc that accepts the specified number of arguments
    # and calls the block with them
    lambda do |*args|
      # Ensure we have the right number of arguments
      if args.length != param_names.length
        return TFL_NULL
      end

      # Call the block with the provided arguments
      begin
        block.call(*args)
      rescue => e
        TFL_NULL
      end
    end
  end

  # FILTER: Filters an array based on a lambda function condition.
  # Returns a new array containing only elements where the lambda returns truthy.
  def tfl_FILTER(array, lambda_func)
    return TFL_NULL if array.nil? || array == TFL_NULL
    return TFL_NULL unless array.is_a?(Array)
    return TFL_NULL if lambda_func.nil? || !lambda_func.respond_to?(:call)

    result = []
    array.each do |element|
      begin
        condition = lambda_func.call(element)
        # Use TFL truthiness rules: only false and TFL_NULL are falsy
        if condition != false && condition != TFL_NULL
          result << element
        end
      rescue => e
        # If the lambda raises an error, skip this element
        next
      end
    end

    result
  end

  # MATCH: Tests if a string matches a regex pattern.
  # Returns true if it matches, false otherwise.
  def tfl_MATCH(text, pattern)
    return TFL_NULL if text.nil? || text == TFL_NULL
    return TFL_NULL if pattern.nil? || pattern == TFL_NULL

    begin
      regex = Regexp.new(pattern.to_s)
      text.to_s.match?(regex)
    rescue RegexpError => e
      TFL_NULL
    end
  end

  # INCLUDES: Checks if an array includes a specific value.
  # Returns true if the value is found, false otherwise.
  def tfl_INCLUDES(array, value)
    return TFL_NULL if array.nil? || array == TFL_NULL
    return false unless array.is_a?(Array)

    array.include?(value)
  end

  # NOT: Logical NOT operation.
  # Returns the opposite boolean value, using TFL truthiness rules.
  def tfl_NOT(value)
    # In TFL, only false and TFL_NULL are falsy
    if value == false || value == TFL_NULL
      true
    else
      false
    end
  end
end
