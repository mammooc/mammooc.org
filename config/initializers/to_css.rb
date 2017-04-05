# frozen_string_literal: true

Sass::Tree::Visitors::ToCss.class_eval do
  # Prepend `prefix` to the output string using the original method from the Gem
  # but only if we are not going to prepend the UTF-8 BOM character

  alias_method :original_prepend!, :prepend!

  def prepend!(prefix)
    original_prepend! prefix unless "\uFEFF".force_encoding(prefix.encoding) == prefix
  end
end
