# lib/tfl_to_ruby/transpiler.rb
#
# Phase 5: The Transpiler Orchestrator
# This class manages the entire pipeline: Lexing, Parsing, and Code Generation.

require_relative 'lexer'
require_relative 'parser'
require_relative 'ast'
require_relative 'runtime/helpers'

module TflToRuby
  class Transpiler
    # The primary method to convert a TFL string into executable Ruby code.
    #
    # @param tfl_expression [String] The source Tines Function Language string.
    # @param data_context_name [String] The name of the variable holding the event data in the output Ruby code (default: 'data_context').
    # @return [String] The generated Ruby code.
    def transpile(tfl_expression, data_context_name: 'data_context')
      # 1. Lexing: Convert the source string into a stream of tokens.
      lexer = Lexer.new(tfl_expression)
      tokens = lexer.tokenize

      # 2. Parsing: Convert the tokens into an Abstract Syntax Tree (AST).
      parser = Parser.new(tokens)
      ast = parser.parse

      # 3. Code Generation: Convert the AST into Ruby code.
      ruby_code = generate_ruby(ast, data_context_name)

      # 4. Final wrap-up with runtime helpers.
      # NOTE: TflRuntime is included in the runner context, so we only need
      # to define the data variable and the expression itself.
      <<~RUBY
        # --- START TFL TRANSPILATION ---
        # The 'data_context' variable is assigned from the running context's 'data' reader.
        #{data_context_name} = data

        # Generated TFL expression logic
        #{ruby_code}
        # --- END TFL TRANSPILATION ---
      RUBY
    end

    private

    # Handles the two primary output cases from the AST:
    # 1. A single expression (e.g., '1 + 2').
    # 2. A sequence of expressions for chaining (e.g., 'a |> UPCASE(%)').
    def generate_ruby(ast, data_context_name)
      if ast.is_a?(ChainExpression)
        # Handle function chaining by generating sequential assignments.
        chain_expressions = ast.to_ruby(context_variable: data_context_name)

        # The output needs to be a block of code where the result of each step
        # is assigned to the placeholder variable `_tfl_result`.
        # The result of the final expression is the last value returned.

        code_lines = []
        chain_expressions.each_with_index do |expr, index|
          if index == 0
            # The first step initializes the result variable
            code_lines << "_tfl_result = #{expr}"
          else
            # Subsequent steps re-assign the result variable
            code_lines << "_tfl_result = #{expr}"
          end
        end

        # Ensure the final line returns the result variable
        code_lines << "_tfl_result"

        code_lines.join("\n")
      else
        # Handle a single, non-chained expression.
        ast.to_ruby(context_variable: data_context_name)
      end
    end
  end
end
