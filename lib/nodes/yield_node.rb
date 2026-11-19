# frozen_string_literal: true

require_relative '../interfaces/leaf_node'

module Antlers
  class YieldNode < BranchNode
    def initialize(name: :default)
      super(name:)
    end

    # Render the children in the binding of the parent. A component used without a slot, like <{ Card }>, has none.
    def render(parent_binding:, slot_node:, current_binding: nil, context: {})
      return '' unless slot_node

      output = ''

      slot_node.children.each do |child|
        output += child.render(current_binding: parent_binding, parent_binding:, slot_node:, context:) || ''
      end

      output
    end

    class << self
      def match?(segment:)
        segment[:slot]
      end

      def build(segment:, **)
        new(name: segment[:slot])
      end
    end
  end
end
