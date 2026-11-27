# frozen_string_literal: true

require_relative '../antlers/compiler'
require_relative '../interfaces/branch_node'

module Antlers
  class RootNode < BranchNode
    def initialize(name: :root_node, children: [])
      super(name:, children:)
    end

    # Renders the template compiled to Ruby, compiling it on its first render, once every node has been parsed.
    # Without a binding, variables render as their text, as the nodes render them.
    def render(current_binding: nil, parent_binding: nil, slot_node: nil, context: {})
      return super unless current_binding

      compile_template unless @compiled
      current_binding.receiver.instance_exec(current_binding, parent_binding, slot_node, context, @data, &@compiled)
    end

    # Renders by walking the nodes, as before compiling. Gives the same HTML as render.
    def interpret(current_binding: nil, parent_binding: nil, slot_node: nil, context: {})
      method(:render).super_method.call(current_binding:, parent_binding:, slot_node:, context:)
    end

    class << self
      def match?(**)
        false
      end

      def build(**)
        new
      end
    end

    private

    def compile_template
      compiler = Compiler.new
      compiled = compiler.compile(@children)
      @data = compiler.data
      @compiled = compiled
    end
  end
end
