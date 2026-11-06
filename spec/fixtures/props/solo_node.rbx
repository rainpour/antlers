# frozen_string_literal: true

require 'lownode'

module RBX
  class SoloNode < LowNode
    def initialize
      @ivar = 'Instance Variable'
    end

    def render
      <html>{@ivar}</html>
    end
  end
end
