# frozen_string_literal: true

require 'lownode'
require_relative '../../../lib/antlers'

module RBX
  # Passes its own slot on to LayoutNode's slot, with a heading of its own.
  class PageShellNode < LowNode
    def initialize
      @heading = 'Shell Heading'
    end

    def render
      <{ LayoutNode: }>
        <h1>{@heading}</h1>
        <{ :slot }>
      <{ :LayoutNode }>
    end
  end

  # Passes its own slot on to PageShellNode's, so it's two slots deep in LayoutNode.
  class SectionShellNode < LowNode
    def render
      <{ PageShellNode: }>
        <section>
          <{ :slot }>
        </section>
      <{ :PageShellNode }>
    end
  end

  # Passes its own slot on to a plain Ruby class, which takes its slot rendered.
  class PlainShellNode < LowNode
    def render
      <{ Simple::SlotNode: title='Plain' }>
        <{ :slot }>
      <{ :Simple::SlotNode }>
    end
  end

  class SlotInSlotNode < LowNode
    def initialize
      @text = 'Page Text'
    end

    def render
      <{ PageShellNode: }>
        <p>{@text}</p>
      <{ :PageShellNode }>
    end
  end

  class SlotInSlotInSlotNode < LowNode
    def initialize
      @text = 'Deep Text'
    end

    def render
      <{ SectionShellNode: }>
        <p>{@text}</p>
      <{ :SectionShellNode }>
    end
  end

  class SlotInPlainSlotNode < LowNode
    def initialize
      @text = 'Plain Text'
    end

    def render
      <{ PlainShellNode: }>
        <p>{@text}</p>
      <{ :PlainShellNode }>
    end
  end
end
