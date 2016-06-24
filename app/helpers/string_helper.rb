# frozen_string_literal: true
module StringHelper
  def self.to_bool(arg)
    return true if arg == true || arg =~ /^(true|t|yes|y|1)$/i
    return false if arg == false || arg =~ /^(false|f|no|n|0)$/i
    raise ArgumentError.new("invalid value for Boolean: \"#{arg}\"")
  end
end
