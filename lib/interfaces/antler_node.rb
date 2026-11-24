# frozen_string_literal: true

require_relative 'lexeme'

module Antlers
  class AntlerNode
    attr_reader :name

    DEF_KEY = nil
    END_KEY = nil

    def initialize(name:)
      @name = name
    end

    def render(current_binding: nil, parent_binding: nil, slot_node: nil, namespace: nil, context: {})
      raise NotImplementedError
    end

    # The name of the end tag that closes this node. Most don't name it, like <{ :if }>, while a slot's has its name.
    def end_name
      Lexeme::NAMELESS_END
    end

    # Support sending an event to render_template hook when lowevent available. See lownode as an example implementation.
    # The parent's params and request are carried over, for the members the installed RenderEvent has.
    def possible_render_event(props:, current_binding: nil)
      return unless defined?(Low::Events::RenderEvent)

      parent = parent_event(current_binding:)
      carried = { params: (parent.params if parent.respond_to?(:params)) || {}, request: (parent.request if parent.respond_to?(:request)) }
      Low::Events::RenderEvent.new(action: :render, props:, **carried.slice(*Low::Events::RenderEvent.members))
    end

    # Renders the node inside a NodeEvent when lowevent has one so the request's tree times it with the events it causes.
    def record_render(node, &)
      return yield unless defined?(Low::Events::NodeEvent)

      Low::Events::NodeEvent.new(node:).record(&)
    end

    # The parent node's event (a RouteEvent or RenderEvent) is the "event" local variable on its binding.
    def parent_event(current_binding:)
      return unless current_binding&.local_variable_defined?(:event)

      current_binding.local_variable_get(:event)
    end

    class << self
      def match?(segment:)
        raise NotImplementedError
      end

      def build(segment:, namespace:)
        raise NotImplementedError
      end
    end

    # Compare instance as a value object.
    def ==(other) = other.class == self.class
    def eql?(other) = self == other
    def hash = [self.class].hash
  end
end
