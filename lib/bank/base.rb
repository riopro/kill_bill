require 'prawn'
require 'prawn/layout'
require 'prawn/fast_png'
require 'barby'
require 'barby/barcode/code_25_interleaved'
require 'barby/outputter/prawn_outputter'

module Riopro
  module KillBill
    module Bank
      class Base

        attr_accessor :bank
        attr_accessor :bank_number
        attr_accessor :bank_number_cd
        attr_accessor :agency
        attr_accessor :agency_cd
        attr_accessor :account
        attr_accessor :account_cd
        attr_accessor :portfolio
        attr_accessor :transferor
        attr_accessor :our_number
        attr_accessor :currency_symbol
        attr_accessor :currency
        attr_accessor :processed_at
        attr_accessor :document_number
        attr_accessor :document_specie
        attr_accessor :documented_at
        attr_accessor :due_on
        attr_accessor :issue_day
        attr_accessor :need_acceptation
        attr_accessor :quantity
        attr_accessor :value
        attr_accessor :payment_text
        # Expects a Hash with { :name, :address1, :address2 }
        attr_accessor :drawee
        # Expects an Array
        attr_accessor :instructions

        def initialize(options={})
          actual_date = options[:current_date] || Date.current
          self.currency_symbol =  "R$"
          self.currency =  "9"
          self.processed_at =  actual_date
          self.document_specie =  "DM"
          self.documented_at =  actual_date
          self.issue_day =  0
          self.need_acceptation =  "N" # maybe it's better admitted
          self.quantity =  1
          self.value =  0.0
          self.payment_text =  "Pagável em Qualquer Banco até o Vencimento"
        end

        # call this method after initialize is mandatory for every class
        # that inherits from KillBill::Bank::Base
        def process_options(options={})
          unless options.empty?
            options.each do |attribute, value|
              self.__send__("#{attribute.to_s}=".to_sym, value)
            end
          end
        end

        #
        # validation for attributes input
        #

        def drawee=(write_drawee)
          raise ArgumentError, "Drawee should be a hash with :name, :address1 and :address2" unless write_drawee.is_a?(Hash)
          raise ArgumentError, "Drawee hash should contain :name" unless write_drawee[:name]
          @drawee = write_drawee
        end

        def instructions=(write_instructions)
          raise ArgumentError, "Instructions should be an array" unless write_instructions.is_a?(Array)
          raise ArgumentError, "Instructions should not be empty" unless write_instructions.size > 0
          @instructions = write_instructions
        end


        # === Stub methods (replace for each bank) ===

        # join instance fields to build barcode string. Each bank has a 
        # different way to build this string. But barcode should have
        # 44 chars and it usual to have a check digit in the middle of
        # the barcode.
        def barcode
          raise "Abstract method called - should overwrite this method on a child class"
          # self.build_barcode(self.calculate_barcode_cd)
        end

        # Builds the base string for bar code. If this method receive the
        # _verifyer_cd_ as parameter, the barcode is ready.
        # This method only exists to make the barcode creation more DRY.
        # Bellow just a sample on how to build the method for your bank
        # Remember: with _verifyer_cd_ your string should have 44 chars
        def build_barcode(verifyer_cd = "")
          raise "Abstract method called - should overwrite this method on a child class"
          # barcode_string =  "#{self.bank_numeber}#{self.currency}#{verifyer_cd}#{self.factor}"
          # barcode_string << "#{self.zeros_at_left(self.value, 10)}#{self.our_number}"
          # barcode_string << "#{self.agency}#{self.account}#{self.portfolio}"
          # barcode_string
        end

        # Calculates our number check digit according to bank criteria
        def calculate_our_number_cd
          raise "Abstract method called - should overwrite this method on a child class"
        end

        # Calculates account check digit according to bank criteria
        def calculate_account_cd
          raise "Abstract method called - should overwrite this method on a child class"
        end

        # parameters that will be used to generate both the pdf file or the pdf stream
        def pdf_parameters(pdf)
          raise "Abstract method called - should overwrite this method on a child class"
        end

        # === End Stub methods (replaced for each bank) ===

        # Render class attributes to pdf file. Returns a pdf stream
        def to_pdf
          @pdf = Prawn::Document.new(:background => File.dirname(__FILE__) + "/../images/#{self.bank.downcase}.png")
          self.pdf_parameters(@pdf)
          @pdf.render
        end

        # Render class attributes to pdf file. Saves pdf to the destination
        # setted in the filename parameter
        def to_pdf_file(filename = nil)
          Prawn::Document.generate(filename, :background => File.dirname(__FILE__) + "/../images/#{self.bank.downcase}.png") do |pdf|
            self.pdf_parameters(pdf)
          end
        end


        # Calculates barcode check digit according to it's
        # build_barcode string
        def calculate_barcode_cd
          code = self.build_barcode
          self.module11_2to9(code)
        end


        # Build billing typeable line. It's a standard pattern for all banks according
        # to BACEN.
        # Returns + nil + if _barcode_ is blank,
        # or if it does not have 44 chars or if it's not a numeric only string
        def typeable_line(barcode="")
          return nil unless  (barcode =~ /^[0-9]{44}$/) && barcode.size == 44

          campo_1_a = "#{barcode[0..3]}"
          campo_1_b = "#{barcode[19..23]}"
          dv_1 = self.module10("#{campo_1_a}#{campo_1_b}")
          campo_1_dv = "#{campo_1_a}#{campo_1_b}#{dv_1}"
          campo_linha_1 = "#{campo_1_dv[0..4]}.#{campo_1_dv[5..9]}"

          campo_2 = "#{barcode[24..33]}"
          dv_2 = self.module10(campo_2)
          campo_2_dv = "#{campo_2}#{dv_2}"
          campo_linha_2 = "#{campo_2_dv[0..4]}.#{campo_2_dv[5..10]}"

          campo_3 = "#{barcode[34..43]}"
          dv_3 = self.module10(campo_3)
          campo_3_dv = "#{campo_3}#{dv_3}"
          campo_linha_3 = "#{campo_3_dv[0..4]}.#{campo_3_dv[5..10]}"

          campo_linha_4 = "#{barcode[4..4]}"

          campo_linha_5 = "#{barcode[5..18]}"

          linha = "#{campo_linha_1} #{campo_linha_2} #{campo_linha_3} #{campo_linha_4} #{campo_linha_5}"

          return linha
        end

        # Calculus Module 10 according to BACEN
        # returns nil if does not receive a only numbers string
        def module10(value = "")
            return nil unless value && (value !~ /[^0-9]+/)

            total = 0
            multiplicador = 2

            for caracter in value.split(//).reverse!
              total += self.digits_sum(caracter.to_i * multiplicador)
              multiplicador = multiplicador == 2 ? 1 : 2
            end

            valor = (10 - (total % 10))
            return valor == 10 ? 0 : valor
        end

        # Calculus Module 11 with multipliers 9 to 2 according to BACEN
        # returns nil if does not receive a only numbers string
        def module11_9to2(value = "")
          return nil unless value && (value !~ /[^0-9]+/)

          multipliers = [9,8,7,6,5,4,3,2]
          total = 0
          position_multiplier = 0

          for caracter in value.split(//).reverse!
            position_multiplier = 0 if (position_multiplier == 8)
            total += (caracter.to_i * multipliers[position_multiplier])
            position_multiplier += 1
          end

          return (total % 11 )
        end

        # Calculus Module 11 with multipliers 2 to 9 according to BACEN
        # returns nil if does not receive a only numbers string
        def module11_2to9(value = "")
          return nil unless value && (value !~ /[^0-9]+/)

          multipliers = [2,3,4,5,6,7,8,9]
          total = 0
          position_multiplier = 0

          for caracter in value.split(//).reverse!
            position_multiplier = 0 if (position_multiplier == 8)
            total += (caracter.to_i * multipliers[position_multiplier])
            position_multiplier += 1
          end

          valor = (11 - (total % 11))
          return [0,10,11].include?(valor) ? 1 : valor
        end


        def module11_2to7P(value = "")
          dv = self.module11_2to7base(value)
          return dv == 10 ? "P" : ( dv == 11 ? 0 : dv )
        end

        def module11_2to7(value = "")
          dv = self.module11_2to7base(value)
          return ([10, 11].include?(dv) ) ? 0 : dv
        end

        # Calculus Module 11 with multipliers 2 to 7
        # returns nil if does not receive a only numbers string
        def module11_2to7base(value = "")
          return nil unless value && (value !~ /[^0-9]+/)

          multipliers = [2,3,4,5,6,7]
          total = 0
          position_multiplier = 0

          for caracter in value.split(//).reverse!
            position_multiplier = 0 if (position_multiplier == 6)
            total += (caracter.to_i * multipliers[position_multiplier])
            position_multiplier += 1
          end

          valor = (11 - (total % 11))
          return valor == 10 ? "P" : ( valor == 11 ? 0 : valor )
        end

        # Sums the digits of a number. Just for _Fixnum_'s
        # Ex. 1 = 1
        #     11 = (1+1) = 2
        #     13 = (1+3) = 4
        #     1ded1 = Error
        def digits_sum(barcode = 0)
          return nil if !barcode.kind_of?(Fixnum)
          return barcode if barcode <= 9

          barcode = barcode.to_s
          total = 0

          0.upto(barcode.size-1) {|digito| total += barcode[digito,1].to_i }

          return total
        end

        # String is filled with zeros at left according to a determinated _size_
        # Default _size_ is 10
        # Ex. value = "12.3"  size = 3 | returns  = "123"
        #     value = "1.23"  size = 4 | returns  = "0123"
        #     value = "123.0" size = 5 | returns = "12300"
        #     value = "123.0"          | returns = "0000012300"
        def zeros_at_left(value = 0.0, size = 10)
          new_value = value.clear_currency_value
          new_value = value.to_s if %w( Fixnum Bignum ).include?(value.class.to_s)
          return new_value if (new_value !~ /\S/)
          diferenca = (size - new_value.size)

          return new_value if (diferenca <= 0)
          return (("0" * diferenca) + new_value )
        end
      end
    end
  end
end