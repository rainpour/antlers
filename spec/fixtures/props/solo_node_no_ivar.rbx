# frozen_string_literal: true

module RBX
  class SoloNodeNoIvar < LowNode
    def render
      <strong>{@ivar}</strong>
    end
  end
end
