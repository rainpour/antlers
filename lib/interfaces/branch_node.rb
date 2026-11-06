# frozen_string_literal: true

require_relative 'antler_node'

module Antlers
  class BranchNode < AntlerNode
    attr_accessor :children

    def initialize(name:, children: [])
      super(name:)

      @children = children
    end

    def render(current_binding: nil, parent_binding: nil, slot_node: nil, context: {})
      output = ''

      @children.each do |child|
        output += child.render(current_binding:, parent_binding:, slot_node:, context:) || ''
      end

      output
    end
  end
end
