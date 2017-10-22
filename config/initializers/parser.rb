# frozen_string_literal: true

JSON::Api::Vanilla.class_eval do
  # Use the original`set_key` method from the Gem but only if
  # we are not going to call a custom method on the nil object

  class <<self
    alias_method :original_set_key, :set_key

    def set_key(obj, key, value, original_keys)
      original_set_key(obj, key, value, original_keys) unless obj.nil?
    end
  end
end
