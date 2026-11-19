# frozen_string_literal: true

require_relative '../interfaces/lexeme'

module Antlers
  module ForLexeme
    include Lexeme
    extend self

    KEYWORDS = ['for:', 'in:', ':for'].freeze

    def match?(keywords:, **)
      KEYWORDS.include?(keywords.keys.first)
    end

    def lexeme(keywords:, **)
      if keywords['for:']
        *key, value = keywords['for:'].split(',').map(&:strip)
        for_def = { for_def: value, in: keywords['in:'] }
        for_def[:key] = key.first unless key.empty?
        return for_def
      end

      # TODO: Keep track of which for loop we're in to allow nested for loops.
      { for_end: NAMELESS_END }
    end
  end
end
