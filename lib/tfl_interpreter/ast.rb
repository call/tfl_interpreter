# lib/tfl_interpreter/ast.rb
#
# Phase 2.2 / Phase 4.2: Abstract Syntax Tree (AST) Definition & Code Generation
#
# Defines the core classes that represent the TFL expression structure and
# implements the #to_ruby method for code generation.

require_relative 'runtime/helpers'

module TflInterpreter
  # Include the TFL runtime methods and constants (like TFL_NULL)
  include TflRuntime

  # Base Node for all AST elements.
  class Node
    # Every node must implement a #to_ruby method
    def to_ruby(context_variable: 'data_context')
      raise NotImplementedError, "#{self.class} must implement #to_ruby"
    end
  end

  # --- 1. Literal Values ---

  # Represents a fixed value (String, Number, TRUE, FALSE, NULL).
  class Literal < Node
    attr_reader :value, :type

    def initialize(value, type)
      @value = value
      @type = type
    end

    def to_ruby(context_variable: 'data_context')
      case @type
      when :TRUE_LITERAL
        'true'
      when :FALSE_LITERAL
        'false'
      when :NULL_LITERAL
        'TflRuntime::TFL_NULL'
      when :NUMBER
        # Ruby handles numbers easily
        @value
      when :STRING
        # String literals are already quoted by the Lexer
        @value
      else
        raise "Unknown literal type: #{@type}"
      end
    end
  end

  class ArrayLiteral < Node
    attr_reader :elements

    def initialize(elements)
      @elements = elements # Array of AST nodes
    end

    def to_ruby(context_variable: 'data_context')
      # Convert each element to Ruby code recursively
      ruby_elements = @elements.map do |elem|
        elem.to_ruby(context_variable: context_variable)
      end.join(', ')

      # Return a Ruby array literal
      "[#{ruby_elements}]"
    end
  end

  # Represents the special TFL placeholder '%' used in function chaining.
  class ChainResult < Node
    # This node generates a simple variable name that the final Interpreter class
    # will use to pass the intermediate result during chaining.
    def to_ruby(context_variable: 'data_context')
      '_tfl_result'
    end
  end

  # --- 2. Data and Variable References ---

  # Represents a reference to external data (e.g., 'action.key', 'user_data').
  class DataReference < Node
    attr_reader :segments

    def initialize(segments)
      @segments = segments
    end

    def to_ruby(context_variable: 'data_context')
      # The first segment is the root context variable (e.g., 'data_context')

      # Convert segments to Ruby arguments for the tfl_get helper
      ruby_segments = @segments.map do |seg|
        if seg.is_a?(Node)
          # Handle complex indices like array[SIZE(list)]
          seg.to_ruby(context_variable: context_variable)
        else
          # Simple string keys/paths (e.g., 'key')
          "'#{seg}'"
        end
      end

      # Uses the runtime helper for safe, nil-tolerant access
      "tfl_get(#{context_variable}, #{ruby_segments.join(', ')})"
    end
  end

  # --- 3. Expressions and Operations ---

  # Represents a binary operation (e.g., 'a > 10', 'b + c').
  class BinaryOperation < Node
    attr_reader :operator, :left, :right

    def initialize(operator, left, right)
      @operator = operator
      @left = left
      @right = right
    end

    def to_ruby(context_variable: 'data_context')
      operator_map = {
        :EQUAL => '==', :NOT_EQUAL => '!=',
        :GREATER => '>', :LESS => '<',
        :GREATER_EQUAL => '>=', :LESS_EQUAL => '<=',
        :PLUS => '+', :MINUS => '-', :STAR => '*', :SLASH => '/'
      }

      # Recursively convert operands and wrap in parentheses for correct precedence
      left_ruby = @left.to_ruby(context_variable: context_variable)
      right_ruby = @right.to_ruby(context_variable: context_variable)

      "(#{left_ruby} #{operator_map[@operator]} #{right_ruby})"
    end
  end

  # Represents a standard TFL function call (e.g., 'UPCASE("text")').
  class FunctionCall < Node
    attr_reader :name, :arguments

    def initialize(name, arguments)
      @name = name
      @arguments = arguments
    end

    def to_ruby(context_variable: 'data_context')
      name_up = @name.upcase

      # Convert all arguments to Ruby code recursively
      ruby_args = @arguments.map do |arg|
        arg.to_ruby(context_variable: context_variable)
      end.join(', ')

      # All TFL functions are translated to custom runtime helpers (tfl_ prefix)
      # to ensure consistent Tines-like behavior (e.g., nil handling, type coercion).
      "tfl_#{name_up}(#{ruby_args})"
    end
  end

  # Represents the TFL function chaining expression ('a |> b').
  class ChainExpression < Node
    attr_reader :left, :right

    def initialize(left, right)
      @left = left
      @right = right # This must be a FunctionCall node
    end

    # For chains, we return a list of expressions to be sequentially executed by
    # the main Interpreter loop, with the result of each step assigned to _tfl_result.
    def to_ruby(context_variable: 'data_context')
      # Get the Ruby code for the left side (could be another chain or a simple expression)
      left_expr_ruby = @left.to_ruby(context_variable: context_variable)

      # Get the Ruby code for the right side (always a function call with % replaced)
      right_call_ruby = @right.to_ruby(context_variable: context_variable)

      # Return an array of expressions to be executed sequentially
      # If left is already a chain, it will return an array, so we need to flatten
      if left_expr_ruby.is_a?(Array)
        left_expr_ruby + [right_call_ruby]
      else
        [left_expr_ruby, right_call_ruby]
      end
    end
  end

  # Represents a LAMBDA function definition
  class LambdaExpression < Node
    attr_reader :param_names, :body_expr

    def initialize(param_names, body_expr)
      @param_names = param_names
      @body_expr = body_expr
    end

    def to_ruby(context_variable: 'data_context')
      params = @param_names.join(', ')

      # When generating the body, we need to replace data references
      # that match parameter names with direct variable references
      body_ruby = convert_params_in_expression(@body_expr, @param_names, context_variable)

      "lambda { |#{params}| #{body_ruby} }"
    end

    private

    def convert_params_in_expression(expr, param_names, context_variable)
      case expr
      when DataReference
        # If this is a simple reference to a parameter, replace it
        if expr.segments.length == 1 && param_names.include?(expr.segments[0])
          return expr.segments[0]
        end
        # Otherwise, check if the first segment is a parameter
        if param_names.include?(expr.segments[0])
          # Convert to parameter access: element.name becomes element['name']
          first = expr.segments[0]
          rest = expr.segments[1..]
          rest_access = rest.map { |seg|
            seg.is_a?(String) ? "['#{seg}']" : "[#{seg.to_ruby(context_variable: context_variable)}]"
          }.join
          return "#{first}#{rest_access}"
        end
        expr.to_ruby(context_variable: context_variable)
      when FunctionCall
        # Recursively convert parameters in function arguments
        args_ruby = expr.arguments.map { |arg|
          convert_params_in_expression(arg, param_names, context_variable)
        }.join(', ')
        "tfl_#{expr.name.upcase}(#{args_ruby})"
      when BinaryOperation
        left = convert_params_in_expression(expr.left, param_names, context_variable)
        right = convert_params_in_expression(expr.right, param_names, context_variable)
        operator_map = {
          EQUAL: '==', NOT_EQUAL: '!=', GREATER: '>', LESS: '<',
          GREATER_EQUAL: '>=', LESS_EQUAL: '<=',
          PLUS: '+', MINUS: '-', STAR: '*', SLASH: '/'
        }
        "(#{left} #{operator_map[expr.operator]} #{right})"
      else
        expr.to_ruby(context_variable: context_variable)
      end
    end
  end
end
