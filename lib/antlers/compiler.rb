# frozen_string_literal: true

require 'cgi/escape'
require_relative '../modules/variables'
require_relative '../support/queries'

module Antlers
  # Compiles a template's nodes into one Ruby lambda, once, so a render runs plain Ruby rather than walking the nodes
  # and reading each variable through the binding. HTML, variables, fors and ifs compile to Ruby. Any other node, like
  # a component, is rendered by its own render method, as it would be without compiling.
  #
  # The lambda runs with the binding's receiver as self, so an instance variable is read as itself. A for's value is a
  # Ruby local, and is also set on the binding when a node inside it renders itself, as that node reads the binding.
  class Compiler
    # Fors' values become Ruby locals, so they must be names that Ruby locals can have.
    LOCAL_NAME = /\A[a-z_][a-zA-Z0-9_]*\z/
    INSTANCE_VARIABLE = /\A@[a-zA-Z_][a-zA-Z0-9_]*\z/

    # What a compiled template calls at runtime.
    module Runtime
      module_function

      # A variable that isn't a for's value or an instance variable: a local on the binding, like a template's params
      # and "event", or else a public method of the receiver.
      def local_or_method(current_binding, name)
        return current_binding.local_variable_get(name) if current_binding.local_variable_defined?(name)

        receiver = current_binding.receiver
        receiver.respond_to?(name) ? receiver.__send__(name) : nil
      end

      # Like Ruby's truthiness, except that a blank string, like '' or ' ', is false. The same as IfNode#shown?.
      def shown?(value)
        return value.strip != '' if value.is_a?(String)

        value
      end
    end

    attr_reader :data

    def initialize
      @lines = []
      @data = [] # Nodes and values the code reads by index, rather than writing them into the code.
      @scope = {} # A for's value names to their Ruby locals.
      @local_count = 0
      @delegated = false
    end

    # A lambda of (current_binding, parent_binding, slot_node, context, data) that returns the rendered string.
    def compile(nodes)
      nodes.each { it.compile(self) }

      code = "# frozen_string_literal: true\n->(b, pb, sn, ctx, data) do\nout = +''\n#{@lines.join("\n")}\nout\nend"
      eval(code, TOPLEVEL_BINDING, "(antlers template #{object_id})", 0) # rubocop:disable Security/Eval
    end

    def emit(line)
      @lines << line
    end

    def html(string)
      emit("out << #{string.inspect}")
    end

    # A node that renders itself, as it would without compiling.
    def delegate(node)
      @delegated = true
      emit("out << (data[#{store(node)}].render(current_binding: b, parent_binding: pb, slot_node: sn, context: ctx) || '')")
    end

    # Compiles nodes with names in scope as Ruby locals. Returns their lines, rather than emitting them, and whether any
    # of the nodes render themselves.
    def with_locals(locals)
      outer_lines = @lines
      outer_scope = @scope
      outer_delegated = @delegated
      @lines = []
      @scope = @scope.merge(locals)
      @delegated = false

      yield
      [@lines, @delegated]
    ensure
      @lines = outer_lines
      @scope = outer_scope
      @delegated ||= outer_delegated
    end

    # A loop over the items, with the names of each item's value, and key if it has one, as Ruby locals. They're set
    # on the binding too when a node inside renders itself, as that node reads them from the binding, like a
    # component's props.
    def for_loop(items:, names:, &)
      item = new_local
      locals = names.to_h { [it, new_local] }
      lines, delegated = with_locals(locals, &)

      emit("(#{expression(items)}).each do |#{item}|")
      emit("#{locals.values.reverse.join(', ')} = #{item}") # Like "key, value = item", as each item is a pair.
      locals.each { |name, local| emit("b.local_variable_set(#{name.to_sym.inspect}, #{local})") } if delegated
      @lines.concat(lines)
      emit('end')
    end

    def new_local
      @local_count += 1
      "l#{@local_count}"
    end

    def local_name?(name)
      name.is_a?(String) && name.match?(LOCAL_NAME)
    end

    # Ruby that reads the expression's value, like "@users" or "Antlers::Queries.read(l1, 'name', :name)".
    def expression(text)
      expression = Variables::Expression.for(text)
      return "data[#{store(expression.value)}]" unless expression.variable?

      expression.path.reduce(variable(expression)) do |value, key|
        "Antlers::Queries.read(#{value}, #{key.inspect}, #{key.to_sym.inspect})"
      end
    end

    # As the interpreter renders a value: HTML escaped unless raw.
    def output(text, raw: false)
      value = "(#{expression(text)}).to_s"
      emit("out << #{raw ? value : "CGI.escapeHTML(#{value})"}")
    end

    private

    def variable(expression)
      name = expression.name
      return @scope[name] if @scope.key?(name)
      return name if expression.instance_variable && name.match?(INSTANCE_VARIABLE)
      return "instance_variable_get(#{name.to_sym.inspect})" if expression.instance_variable

      "Antlers::Compiler::Runtime.local_or_method(b, #{name.to_sym.inspect})"
    end

    def store(value)
      @data << value
      @data.size - 1
    end
  end
end
