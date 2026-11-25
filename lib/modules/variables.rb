# frozen_string_literal: true

require 'cgi/escape'
require 'lowkey'

require_relative '../support/queries'

module Antlers
  module Variables
    # What an expression is depends only on its text, so it's read once rather than on every render: a value, or a
    # variable (an instance variable, or a local variable or method) with the path to read from it.
    Expression = Data.define(:value, :name, :path, :instance_variable) do
      def variable? = !name.nil?

      class << self
        def for(text)
          self::CACHE.fetch(text) do
            self::CACHE.clear if self::CACHE.size >= self::CACHE_LIMIT
            self::CACHE[text.dup.freeze] = parse(text)
          end
        end

        private

        def parse(text)
          literal = true
          value = Lowkey::ValueParser.parse(text) { literal = false }
          return value(value) if literal
          return value(text[1..-2]) if Queries.user_defined_string?(text)

          name, *path = text.split('.')
          new(value: nil, name: name.freeze, path: path.each(&:freeze).freeze, instance_variable: name.start_with?('@'))
        end

        # Shared by every render, so a string is frozen.
        def value(value) = new(value: value.is_a?(String) ? value.freeze : value, name: nil, path: [].freeze, instance_variable: false)
      end
    end
    # A template has a fixed set of expressions, but props can be built, so the cache is bounded.
    Expression::CACHE = {} # rubocop:disable Style/MutableConstant
    Expression::CACHE_LIMIT = 10_000

    # Evaluation limited to the following for security and to stop a templating language becoming a programming language.
    #  1. A value ('string', 3, 1.5, true, nil or :symbol)
    #  2. Invalid string ("Hi #{name}", 'it's', 'a' + 'b')
    #  3. An instance variable
    #  4. A method call/local variable
    #  5. A nested path (a hash's key, an array's or string's basic methods, an object's public method)
    def evaluate(value:, current_binding:, escape: true)
      result = result(value:, current_binding:)

      return CGI.escapeHTML(result.to_s) if escape

      result
    end

    def result(value:, current_binding:)
      expression = Expression.for(value)
      return expression.value unless expression.variable?
      return value unless current_binding

      result = method_var(expression:, current_binding:)
      return Queries.read_path(value: result, path: expression.path) unless expression.path.empty?

      result
    end

    private

    def method_var(expression:, current_binding:)
      name = expression.name
      return current_binding.receiver.instance_variable_get(name) if expression.instance_variable
      return current_binding.local_variable_get(name) if current_binding.local_variable_defined?(name)
      return current_binding.receiver.send(name.to_sym) if current_binding.receiver.respond_to?(name.to_sym)

      nil
    end
  end
end
