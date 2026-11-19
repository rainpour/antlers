# frozen_string_literal: true

require_relative '../interfaces/lexeme'

module Antlers
  # A form, like "<{ form: '/search' method: 'GET' class='search' }>": its action, its method, and HTML attributes.
  module FormLexeme
    include Lexeme
    extend self

    KEYWORDS = ['form:', ':form'].freeze
    # The action, a quoted path or a variable, then each "name: 'value'" or "name='value'".
    ACTION = /\A\s*('[^']*'|"[^"]*"|[^\s'"]+)/
    OPTION = /([a-z][\w-]*)(?::\s*|=)('[^']*'|"[^"]*")/

    def match?(keywords:, **)
      KEYWORDS.include?(keywords.keys.first)
    end

    def lexeme(keywords:, **)
      return { form_end: NAMELESS_END } unless keywords.key?('form:')

      definition = keywords['form:'].to_s
      action = definition[ACTION, 1]
      options = definition.delete_prefix(action.to_s).scan(OPTION).to_h { |name, value| [name, value[1..-2]] }
      method = options.delete('method')
      { form_def: action }.merge({ method:, attributes: (options unless options.empty?) }.compact)
    end
  end
end
