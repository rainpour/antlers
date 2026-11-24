# frozen_string_literal: true

require_relative '../antlers/keywords'
require_relative '../interfaces/branch_node'
require_relative '../modules/namespace'
require_relative '../modules/props'

module Antlers
  class SlotNode < BranchNode
    include Namespace
    include Props # The immediate ancestor which props are passed to.

    DEF_KEY = :slot_def
    END_KEY = :slot_end

    # What a component's <{ :slot }> renders: this node's children, in the binding of the template they're written in,
    # with that template's own slot and parent binding. So a <{ :slot }> among them renders what that template was
    # given, rather than these children again.
    Filling = Data.define(:node, :binding, :slot_node, :parent_binding) do
      def children = node.children
    end

    attr_accessor :children

    def initialize(name:, namespace:, props: {}, children: [], **)
      super(name:, props:, children:)

      @namespace = namespace
    end

    def render(current_binding: nil, parent_binding: nil, slot_node: nil, context: {})
      props = evaluate_props(props: @props, current_binding:)
      klass = class_constant(namespace: @namespace&.split('::') || [], name:)
      event = possible_render_event(props:, current_binding:)
      filling = Filling.new(node: self, binding: current_binding, slot_node:, parent_binding:)
      record_render(klass) { render_slot_node(klass:, props:, event:, filling:, context:) }
    end

    def render_slot_node(klass:, props:, event:, filling:, context:)
      keywords = props.merge(event:)
      instance = klass.new(**Keywords.accepted(klass.instance_method(:initialize), keywords))

      # Classes referenced via "<{ ChildNode }>" must implement class/instance render/render_template methods (See LowNode).
      if klass.respond_to?(:template) && klass.template
        return instance.render_template(event:, parent_binding: filling.binding, slot_node: filling, props:, context:)
      end

      # Without a class template, a component's own render method can receive its slot's rendered children as slot:.
      render_method = instance.method(:render)
      keywords[:slot] = slot(filling:, context:) if Keywords.takes?(render_method, :slot)
      instance.render(**Keywords.accepted(render_method, keywords))
    end

    # The children rendered in the binding the slot is in, like a yield in a template renders them.
    def slot(filling:, context:)
      @children.map do |child|
        child.render(current_binding: filling.binding, parent_binding: filling.parent_binding, slot_node: filling.slot_node,
                     context:) || ''
      end.join
    end

    def end_name
      @name
    end

    class << self
      def match?(segment:)
        segment[DEF_KEY]
      end

      def build(segment:, namespace:, **)
        new(name: segment[DEF_KEY], props: segment[:props], namespace:)
      end
    end
  end
end
