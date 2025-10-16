# lib/tfl_to_ruby/lexer.rb
#
# Phase 2.1: Lexical Analysis (Tokenization)

module TflToRuby
  # --- 1. Token Definition ---
  # A simple struct to hold the token type and the value (literal or source text).
  # This makes the output of the Lexer easy for the Parser to consume.
  Token = Struct.new(:type, :value)

  class Lexer
    # --- Token Types ---
    # Define constants for all token types the lexer will recognize.
    # We use symbols for consistency and performance in Ruby.
    TOKEN_TYPES = {
      # Data Types and Literals
      :STRING        => /"([^"\\]|\\.)*"|'([^'\\]|\\.)*'/, # Single or double quoted strings
      :NUMBER        => /\d+(\.\d+)?/,                   # Integers or floating-point numbers
      :TRUE_LITERAL  => /TRUE/,
      :FALSE_LITERAL => /FALSE/,
      :NULL_LITERAL  => /NULL/,

      # Special Values
      :PERCENT       => /%/,                             # The chaining result placeholder (%)

      # Structure and Punctuation
      :LPAREN        => /\(/,                             # Left parenthesis (
      :RPAREN        => /\)/,                             # Right parenthesis )
      :LBRACKET      => /\[/,                             # Left bracket [
      :RBRACKET      => /\]/,                             # Right bracket ]
      :COMMA         => /,/,                              # Comma ,
      :DOT           => /\./,                             # Dot . (for object access: action.key)

      # Operators
      :PIPE_CHAIN    => /\|>/,                            # Function chaining operator |>
      :EQUAL         => /=/,                              # Equality =
      :NOT_EQUAL     => /!=/,
      :GREATER       => />/,
      :LESS          => /</,
      :GREATER_EQUAL => />=/,
      :LESS_EQUAL    => /<=/,
      :PLUS          => /\+/,
      :MINUS         => /-/,
      :STAR          => /\*/,
      :SLASH         => /\//,

      # Function Names and Identifiers (must be last, as they are catch-alls)
      # TFL functions are typically UPPERCASE. Identifiers are usually snake_case/camelCase
      :IDENTIFIER    => /[a-zA-Z_][a-zA-Z0-9_]*/,

      # Ignore token types
      :WHITESPACE    => /\s+/,
      :COMMENT       => /#.*/ # Tines uses '#' for comments
    }.freeze

    def initialize(input_string)
      @input = input_string.strip
      @position = 0
      @tokens = []
    end

    # Scans the input string and generates an array of tokens.
    def tokenize
      @tokens = []
      while @position < @input.length
        match_found = false
        TOKEN_TYPES.each do |type, regex|
          # Use a non-capturing group for the whole match
          # The regex must anchor to the start of the current string slice
          if (match = @input[@position..].match(/^#{regex}/))
            value = match[0]
            @position += value.length

            # Skip whitespace and comments
            unless type == :WHITESPACE || type == :COMMENT
              @tokens << Token.new(type, value)
            end

            match_found = true
            break # Move to the next position in the input string
          end
        end

        # If no regex matched, we have an unexpected character.
        unless match_found
          raise "Lexing Error: Unexpected character '#{@input[@position]}' at position #{@position}"
        end
      end

      return @tokens
    end
  end
end
