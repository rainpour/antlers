# frozen_string_literal: true

require 'lownode'
require_relative '../../../lib/antlers'

module RBX
  class SlotNodeWithChild < LowNode
    def initialize
      @ivar = 'Parent Variable'
    end

    def render
      <{ LayoutNode: }>
        <{ SoloNodeVar var=@ivar }>
      <{ :LayoutNode }>
    end
  end
end
