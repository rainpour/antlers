# frozen_string_literal: true

module Antlers
  class Parser
    class ParserError < StandardError; end

    def initialize(node_types:, namespace: nil)
      @node_types = node_types.to_a
      @namespace = namespace
      @template = nil
    end

    def parse(sequence:, template: nil, id: :root_node)
      @template = template

      branch(node: RootNode.new(name: id), sequence:)
    end

    def branch(node:, sequence:)
      until sequence.empty?
        segment = sequence.shift

        child_class = @node_types.find { |n| n.match?(segment:) }
        raise(ParserError, "No node matches #{segment}") unless child_class

        child = child_class.build(segment:, namespace: @namespace, template: @template)
        node.children << child

        if (end_key = child_class::END_KEY)
          sub_branch(node: child, sequence:, end_key:, end_name: child.end_name)
        end
      end

      node
    end

    # Takes the segments up to the node's own end tag. A node of the same kind can open inside it, like an if in an if,
    # and the end tags up to as many as have opened are theirs.
    def sub_branch(node:, sequence:, end_key:, end_name: nil)
      sub_sequence = []
      depth = 0

      loop do
        raise ParserError, "Missing end tag for #{node.class}" if sequence.empty?

        segment = sequence.first
        if end_tag?(segment, end_key, end_name)
          break if depth.zero?

          depth -= 1
        elsif opens_same_kind?(node, segment, end_name)
          depth += 1
        end
        sub_sequence << sequence.shift
      end

      # Remove the end tag we just stopped before.
      sequence.shift

      branch(node:, sequence: sub_sequence)
    end

    private

    def end_tag?(segment, end_key, end_name)
      segment.is_a?(Hash) && segment[end_key] == end_name
    end

    # Whether the segment opens a node that the same end tag closes, like any if, or a slot with the same name.
    def opens_same_kind?(node, segment, end_name)
      return false unless segment.is_a?(Hash) && segment.key?(node.class::DEF_KEY)

      end_name == Lexeme::NAMELESS_END || segment[node.class::DEF_KEY] == end_name
    end
  end
end
