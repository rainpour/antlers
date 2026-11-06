# frozen_string_literal: true

require_relative 'antlers/elements'
require_relative 'antlers/keywords'
require_relative 'antlers/lexer'
require_relative 'antlers/parser'
require_relative 'antlers/translations'

module Antlers
  module_function

  DEFAULT_ELEMENTS = %i[root html form for if solo slot yield var].freeze

  def ast(template:, namespace: nil, elements: Elements[*DEFAULT_ELEMENTS])
    sequence = Lexer.new(lexeme_types: elements[:lexeme]).parse(template:)
    Parser.new(namespace:, node_types: elements[:node]).parse(sequence:, template:)
  end

  def render(ast:, current_binding:, parent_binding: nil, slot_node: nil, context: {})
    ast.render(current_binding:, parent_binding:, slot_node:, context:)
  end

  # Call once an app has loaded, to find solo nodes built before their class loaded.
  # Returns the solo nodes whose class is still undefined, which look up their class when first rendered.
  def resolve_nodes
    SoloNode.resolve
  end
end
