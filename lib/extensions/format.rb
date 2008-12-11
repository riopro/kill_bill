## Copiado de acts_as_payment
## http://github.com/kivanio/acts_as_payment/tree
##
## Modulo de Formatacao
##
module Riopro
  module KillBill
    module Extensions
      module Format

        def to_br_cpf
          return (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{3})(.{3})(.{3})(.{2})$/,'\1.\2.\3-\4')
        end

        def to_br_cep
          return (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{5})(.{3})$/,'\1-\2')
        end

        def to_br_cnpj
          return (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/,'\1.\2.\3/\4-\5')
        end

        def to_br_ie
          return (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{2})(.{3})(.{3})(.{1})$/,'\1.\2.\3-\4')
        end

        def formata_documento
          case (self.kind_of?(String) ? self : self.to_s).size
          when 8 then self.to_br_cep
          when 11 then self.to_br_cpf
          when 14 then self.to_br_cnpj
          when 9 then self.to_br_ie
          else
            self
          end
        end

        def clear_currency_value
          return self unless self.kind_of?(String) && self.is_currency?
          return self.numbers_only
        end

        def numbers_only
          return self unless self.kind_of?(String)
          return self.gsub(/\D/,'')
        end
      end
    end
  end
end