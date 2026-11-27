# frozen_string_literal: true

require 'lownode'

module RBX
  # A template with what compiles to Ruby (HTML, variables, fors and ifs) around what renders itself (components).
  class CompiledNode < LowNode
    Item = Data.define(:name, :tags)

    def initialize
      @items = [Item.new('<b>One</b>', %w[red blue]), Item.new('Two', [])]
      @groups = { odd: [1, 3], even: [2] }
    end

    def heading = 'Items & more'

    def render
      <h1>{heading}</h1>
      <ul>
        <{ for: item in: @items }>
          <li>
            {item.name}
            <{ if: item.tags.first }><em>{item.tags.size} tags</em><{ :if }>
            <{ for: tag in: item.tags }><{ SoloNodeVar var=tag }><{ :for }>
          </li>
        <{ :for }>
      </ul>
      <{ for: name, numbers in: @groups }>
        <p>{name}: {numbers.first} to {numbers.last}, {3}</p>
      <{ :for }>
      <p>{@missing}{missing}</p>
    end
  end
end
