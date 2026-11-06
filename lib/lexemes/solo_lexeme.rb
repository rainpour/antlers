# frozen_string_literal: true

require_relative '../interfaces/lexeme'

module Antlers
  module SoloLexeme
    include Lexeme
    extend self

    def match?(name:, **)
      name && [*'A'..'Z'].include?(name[0]) && !(name.start_with?(':') || name.end_with?(':'))
    end

    def lexeme(name:, props:, **)
      solo = { solo: name }
      solo[:props] = props(props) unless props.empty?
      solo
    end
  end
end
