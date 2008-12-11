## Copiado de acts_as_payment
## http://github.com/kivanio/acts_as_payment/tree
#
# Que usou:
#
# Implementação feita por Nando Vieira do http://simplesideias.com.br
# post http://simplesideias.com.br/usando-number_to_currency-em-modelos-no-rails

module Riopro
  module KillBill
    module Extensions
      module Currency
        BRL = {:delimiter => ".", :separator => ",", :unit => "R$", :precision => 2, :position => "before"}
        USD = {:delimiter => ',', :separator => ".", :unit => "US$", :precision => 2, :position => "before"}
        DEFAULT = BRL.merge(:unit => "")

        module String
          def to_number(options={})
            return self.gsub(/,/, '.').to_f if self.numeric?
            nil
          end

          def numeric?
            self =~ /^(\+|-)?[0-9]+((\.|,)[0-9]+)?$/ ? true : false
          end
        end

        module Number
          def to_currency(options = {})
            number = self
            default   = Currency::DEFAULT.stringify_keys
            options   = default.merge(options.stringify_keys)
            precision = options["precision"] || default["precision"]
            unit      = options["unit"] || default["unit"]
            position  = options["position"] || default["position"]
            separator = precision > 0 ? options["separator"] || default["separator"] : ""
            delimiter = options["delimiter"] || default["delimiter"]

            begin
              parts = number.with_precision(precision).split('.')
              number = parts[0].to_i.with_delimiter(delimiter) + separator + parts[1].to_s
              position == "before" ? unit + number : number + unit
            rescue
              number
            end
          end

          def with_delimiter(delimiter=",", separator=".")
            number = self
            begin
              parts = number.to_s.split(separator)
              parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
              parts.join separator
            rescue
              self
            end
          end

          def with_precision(precision=3)
            number = self
            "%01.#{precision}f" % number
          end
        end
      end
    end
  end
end