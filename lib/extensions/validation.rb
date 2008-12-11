##
## Validation Module
##
module Riopro
  module KillBill
    module Extensions
      module Validation

        # Verifyes if value is a number
        # Ex. +1.232.33
        # Ex. -1.232.33
        # Ex. +1,232.33
        # Ex. -1,232.33
        # Ex. +1.232,33
        # Ex. -1.232,33
        # Ex. +1,232,33
        # Ex. -1,232,33
        def is_currency?
          return false unless self.kind_of?(String)
          self =~ /^(\+|-)?\d+((\.|,)\d{3}*)*((\.|,)\d{2}*)$/ ? true : false
        end
      end
    end
  end
end