module GlobalHelper

  module ApplicationConstants
    def constant_keys
      self.constants
    end

    def constant_values
      self.constant_keys.collect { |sym| self.const_get(sym) }
    end
  end
end
