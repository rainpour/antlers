# frozen_string_literal: true

module Antlers
  module Queries
    BASIC_TYPES = [Symbol, Numeric, TrueClass, FalseClass, NilClass].freeze
    ENUMERABLE_ALLOWLIST = %w[first last size].freeze
    STRING_ALLOWLIST = %w[upcase downcase].freeze

    class << self
      def user_defined_string?(string)
        wrapped_in?(string, "'") || wrapped_in?(string, '"')
      end

      # Strings like {"Hello"} and symbols like {:app_name} are translated, but not methods or instance variables.
      def translatable?(string)
        user_defined_string?(string) || string.start_with?(':')
      end

      def wrapped_in?(string, delimeter)
        string[0] == delimeter && string[-1] == delimeter
      end

      def read_path(value:, path:)
        path.reduce(value) do |current_value, key|
          case current_value
          when Hash then read_hash(current_value, key:)
          when Array then read_array(current_value, key:)
          when String then read_string(current_value, key:)
          when *BASIC_TYPES then nil
          else current_value.public_send(key.to_sym)
          end
        end
      end

      private

      def read_hash(hash, key:)
        hash.fetch(key) do
          hash.fetch(key.to_sym) do
            call_enumerable_method(hash, key:)
          end
        end
      end

      def read_array(array, key:)
        index = Integer(key, exception: false)
        return array[index] if index

        call_enumerable_method(array, key:)
      end

      def read_string(string, key:)
        string.public_send(key) if STRING_ALLOWLIST.include?(key)
      end

      def call_enumerable_method(enumerable, key:)
        # A hash has no last method so fail gracefully.
        enumerable.public_send(key) if ENUMERABLE_ALLOWLIST.include?(key) && enumerable.respond_to?(key)
      end
    end
  end
end
