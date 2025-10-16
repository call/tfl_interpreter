# lib/tfl_to_ruby/runtime/helpers.rb
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

  # Placeholder for JOIN function if needed later
  def tfl_JOIN(array, separator)
    # Simple implementation: ignores separator if array is not an array.
    return TFL_NULL unless array.is_a?(Array) && separator.is_a?(String)
    array.join(separator)
  end
end
