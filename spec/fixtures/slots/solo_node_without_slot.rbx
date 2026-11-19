# frozen_string_literal: true

require 'lownode'
require_relative '../../../lib/antlers'

module RBX
  class SoloNodeWithoutSlot < LowNode
    def render
      <{ LayoutNodeWithProp emotion='Happy' }>
    end
  end
end
