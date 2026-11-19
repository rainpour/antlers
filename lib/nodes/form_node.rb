# frozen_string_literal: true

require 'cgi/escape'
require_relative '../interfaces/branch_node'
require_relative '../modules/props'
require_relative '../modules/variables'

module Antlers
  # A form, posted to its action. A POST form gets a hidden form_token field from Antlers.form_token, when a framework
  # sets it, so a form posted from another site can be turned away.
  class FormNode < BranchNode
    include Props
    include Variables

    DEF_KEY = :form_def
    END_KEY = :form_end
    TOKEN_FIELD = 'form_token'
    METHODS = %w[GET POST].freeze

    def initialize(name:, action: nil, method: 'POST', attributes: {}, props: [], children: []) # rubocop:disable Metrics/ParameterLists
      super(name:, props:, children:)

      @action = action
      @method = method.to_s.upcase
      raise ArgumentError, "A form's method is GET or POST, not #{method}" unless METHODS.include?(@method)

      @attributes = attributes.map { |name, value| " #{name}='#{CGI.escapeHTML(value.to_s)}'" }.join
    end

    def render(current_binding: nil, parent_binding: nil, slot_node: nil, context: {})
      output = +"<form action='#{action(current_binding:)}' method='#{@method}'#{@attributes}>"
      output << token_field(current_binding:)

      @children.each do |child|
        output << (child.render(current_binding:, parent_binding:, slot_node:, context:) || '')
      end

      output << '</form>'
    end

    private

    def action(current_binding:)
      return if @action.nil?

      evaluate(value: @action, current_binding:)
    end

    def token_field(current_binding:)
      return '' unless @method == 'POST' && Antlers.form_token

      token = Antlers.form_token.call(current_binding)
      return '' unless token

      "<input type='hidden' name='#{TOKEN_FIELD}' value='#{CGI.escapeHTML(token)}'>"
    end

    class << self
      def match?(segment:)
        segment.is_a?(Hash) && segment.key?(DEF_KEY)
      end

      def build(segment:, **)
        action, method, attributes = segment.values_at(DEF_KEY, :method, :attributes)
        new(name: action, action:, method: method || 'POST', attributes: attributes || {})
      end
    end
  end
end
