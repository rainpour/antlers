# frozen_string_literal: true

require_relative '../interfaces/lexeme'

module Antlers
  module IfLexeme
    include Lexeme
    extend self

    KEYWORDS = ['if:', ':if'].freeze

    def match?(keywords:, **)
      KEYWORDS.include?(keywords.keys.first)
    end

    def lexeme(keywords:, **)
      return { if_def: keywords['if:'] } if keywords.key?('if:')

      { if_end: NAMELESS_END }
    end
  end
end
