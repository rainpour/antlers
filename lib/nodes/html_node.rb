# frozen_string_literal: true

require_relative '../interfaces/leaf_node'

module Antlers
  class HTMLNode < LeafNode
    def initialize(html:)
      super(name: nil)

      @html = html
    end

    def render(**)
      @html
    end

    def compile(compiler)
      compiler.html(@html)
    end

    class << self
      def match?(segment:)
        segment.is_a?(String)
      end

      def build(segment:, **)
        new(html: segment)
      end
    end
  end
end
