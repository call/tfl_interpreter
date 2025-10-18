# lib/tfl_to_ruby/parser.rb
#
# Phase 2.2: Parser (Token Stream -> AST)
require_relative 'lexer'
require_relative 'ast'

module TflToRuby
  class Parser
    include TflToRuby # Include the module to access Token and AST classes

    # Define operator precedence for binary operations (highest to lowest)
    PRECEDENCE = {
      :STAR  => 5, :SLASH => 5,
      :PLUS  => 4, :MINUS => 4,
      :EQUAL => 3, :NOT_EQUAL => 3,
      :GREATER => 3, :LESS => 3,
      :GREATER_EQUAL => 3, :LESS_EQUAL => 3
    }.freeze

    def initialize(tokens)
      @tokens = tokens
      @current = 0 # Index of the current token
    end

    # --- Utility Methods for Token Stream Management ---

    def peek
      @tokens[@current]
    end

    def advance
      token = peek
      @current += 1 unless end_of_file?
      token
    end

    def end_of_file?
      @current >= @tokens.length
    end

    # Consumes the current token if its type matches, otherwise raises an error.
    def consume(expected_type, message = nil)
      token = advance
      unless token && token.type == expected_type
        error_msg = message || "Expected #{expected_type} but found #{token ? token.type : 'EOF'}"
        raise "Parsing Error: #{error_msg}"
      end
      token
    end

    # --- Core Parsing Methods ---

    # Entry point: Parses the entire expression, starting with the highest precedence (chaining)
    def parse
      # TFL expressions can be a single expression or a chain of expressions
      left = parse_expression(0)

      while peek && peek.type == :PIPE_CHAIN
        operator = advance # Consume the |>
        right = parse_function_call # The right side of a chain MUST be a function call
        left = ChainExpression.new(left, right)
      end

      left
    end

    # Parses expressions based on operator precedence (precedence climbing)
    def parse_expression(precedence)
      left = parse_primary # Get the base element (literal, reference, or function call)

      while peek && PRECEDENCE.include?(peek.type) && PRECEDENCE[peek.type] > precedence
        operator_token = advance
        op_precedence = PRECEDENCE[operator_token.type]
        right = parse_expression(op_precedence)
        left = BinaryOperation.new(operator_token.type, left, right)
      end

      left
    end

   # Parses the most fundamental components: literals, references, or grouped expressions.
    def parse_primary
      token = peek

      return case token.type
      when :NUMBER, :STRING, :TRUE_LITERAL, :FALSE_LITERAL, :NULL_LITERAL
        advance
        Literal.new(token.value, token.type)

      when :PERCENT
        advance
        ChainResult.new

      when :LPAREN
        advance # Consume '('
        expr = parse # Parse the expression inside the parentheses
        consume(:RPAREN, "Mismatched parentheses. Expected ')'")
        expr

      when :LBRACKET
        parse_array_literal

      when :IDENTIFIER
        # An identifier can be a FunctionCall or the start of a DataReference.
        if @tokens[@current + 1] && @tokens[@current + 1].type == :LPAREN
          parse_function_call
        else
          parse_data_reference
        end

      else
        raise "Parsing Error: Unexpected token '#{token.value}' (#{token.type}) at primary expression"
      end
    end

    # Parses an array literal (e.g., '[1, 2, 3]' or '["a", "b"]')
    def parse_array_literal
      consume(:LBRACKET, "Expected '[' to start array literal")

      elements = []

      # Check for empty array
      unless peek.type == :RBRACKET
        loop do
          elements << parse_expression(0)
          break unless peek.type == :COMMA
          consume(:COMMA)
        end
      end

      consume(:RBRACKET, "Mismatched brackets. Expected ']' after array elements")

      ArrayLiteral.new(elements)
    end
    # Parses a complete data reference (e.g., 'event_data.user.id' or 'array[0]')
    def parse_data_reference
      segments = []

      # The first token MUST be an identifier (e.g., 'event_data')
      segments << consume(:IDENTIFIER).value

      # Handle subsequent dots (object access) or brackets (array access)
      while peek && (peek.type == :DOT || peek.type == :LBRACKET)
        if peek.type == :DOT
          consume(:DOT)
          # The next segment must be an identifier (e.g., 'user')
          segments << consume(:IDENTIFIER).value
        elsif peek.type == :LBRACKET
          consume(:LBRACKET)
          # TFL allows literals or other expressions inside brackets (e.g., array[SIZE(list)]).
          index_expr = parse_expression(0) # Parse the index/key expression
          segments << index_expr
          consume(:RBRACKET, "Mismatched brackets. Expected ']'")
        end
      end

      DataReference.new(segments)
    end

    # Parses a function call (e.g., 'JOIN("A", "B")')
    def parse_function_call
      name_token = consume(:IDENTIFIER, "Expected function name (IDENTIFIER)")
      consume(:LPAREN, "Function '#{name_token.value}' must be followed by '('")

      arguments = []

      # Check for zero arguments
      unless peek.type == :RPAREN
        loop do
          arguments << parse_expression(0)
          break unless peek.type == :COMMA
          consume(:COMMA)
        end
      end

      consume(:RPAREN, "Mismatched parentheses. Expected ')' after function arguments")

      FunctionCall.new(name_token.value, arguments)
    end
  end
end
