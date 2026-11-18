# frozen_string_literal: true

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

    def end_name
      'level_1'
    end

    # Support sending an event to render_template hook when lowevent available. See lownode as an example implementation.
    # The parent's params and request are carried over, for the members the installed RenderEvent has.
    def possible_render_event(props:, current_binding: nil)
      return unless defined?(Low::Events::RenderEvent)

      parent = parent_event(current_binding:)
      carried = { params: (parent.params if parent.respond_to?(:params)) || {}, request: (parent.request if parent.respond_to?(:request)) }
      Low::Events::RenderEvent.new(action: :render, props:, **carried.slice(*Low::Events::RenderEvent.members))
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
