# frozen_string_literal: true

require 'plugs'

module Antlers
  class Elements
    include Plugs

    plug(:root) do
      plug(:node) do
        require_relative '../nodes/root_node'
        RootNode
      end
    end

    plug(:html) do
      plug(:node) do
        lazy do
          require_relative '../nodes/html_node'
          HTMLNode
        end
      end
    end

    plug(:form) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/form_lexeme'
          FormLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/form_node'
          FormNode
        end
      end
    end

    plug(:for) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/for_lexeme'
          ForLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/for_node'
          ForNode
        end
      end
    end

    plug(:if) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/if_lexeme'
          IfLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/if_node'
          IfNode
        end
      end
    end

    plug(:solo) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/solo_lexeme'
          SoloLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/solo_node'
          SoloNode
        end
      end
    end

    plug(:slot) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/slot_lexeme'
          SlotLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/slot_node'
          SlotNode
        end
      end
    end

    plug(:yield) do
      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/yield_lexeme'
          YieldLexeme
        end
      end

      plug(:node) do
        lazy do
          require_relative '../nodes/yield_node'
          YieldNode
        end
      end
    end

    plug(:var) do
      plug(:node) do
        lazy do
          require_relative '../nodes/var_node'
          VarNode
        end
      end

      plug(:lexeme) do
        lazy do
          require_relative '../lexemes/var_lexeme'
          VarLexeme
        end
      end
    end
  end
end
