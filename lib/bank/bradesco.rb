module Riopro
  module KillBill
    module Bank
      class Bradesco < Riopro::KillBill::Bank::Base

        attr_accessor :cpf_or_cnpj
        # Expects an Array describing services included in this billing
        attr_accessor :descriptions

        # bank default options
        def initialize(options = {})
          super
          self.bank = "bradesco"
          self.bank_number = 237
          self.bank_number_cd = 2
          self.portfolio = 9 # carteira "sem registro"

          # call this method after initialize is mandatory for every class
          # that inherits from KillBill::Bank::Base
          self.process_options(options)
        end

        #
        # validation for attributes input
        #

        def descriptions=(write_descriptions)
          raise ArgumentError, "Drawee should be an Array" unless write_descriptions.is_a?(Array)
          @descriptions = write_descriptions
        end


        # Retorna a string de números formatada com o código de barras
        # Para ser válido, o código de barras retornável tem que ter 44 caracteres
        def barcode
          self.account_cd = self.calculate_account_cd
          @formatted_value = self.zeros_at_left(self.value,10)
          @factor = self.due_on.due_day_factor
          self.our_number = self.zeros_at_left(self.our_number,8)

          self.build_barcode(self.calculate_barcode_cd)
        end

        # Monta o código de barras com 43 ou 44 caracteres, dependendo se recebeu
        # ou não o dígito verificador do código de barras. Assim o código fica
        # mais DRY.
        def build_barcode(verifyer_cd = "")
          barcode = "#{self.bank_number}#{self.currency}#{verifyer_cd}#{@factor}#{@formatted_value}#{self.agency}"
          barcode << "#{self.portfolio}#{self.our_number}"
          barcode << "#{self.account}0"
          barcode
        end

        # Calculates our number check digit according to Itaú criteria
        def calculate_our_number_cd
          module10("#{self.agency}#{self.account}#{self.portfolio}#{self.our_number}");
        end

        # Calculates account check digit according to Bradesco criteria
        def calculate_account_cd
          module10("#{self.agency}#{self.account}")
        end

        # parameters that will be used to generate both the pdf file or the pdf stream
        def pdf_parameters(pdf)
          @barcode = self.barcode
          pdf.font.size = 8
          # User receipt
          pdf.move_down 86
          data = [ [self.transferor, "#{self.agency}/#{self.account}-#{self.account_cd}", self.currency_symbol, {:text => self.quantity, :align => :center}, "#{self.our_number}-#{self.calculate_our_number_cd}"]]
          pdf.table data, TABLE_DEFAULTS.merge(:widths => { 0 => 270, 1 => 96, 2 => 44, 3 => 40, 4 => 100})
          data = [ [self.document_number, self.cpf_or_cnpj, self.due_on.to_s_br, self.value.to_currency ]]
          pdf.table data, TABLE_DEFAULTS.merge(:widths => { 0 => 160, 1 => 120, 2 => 120, 3 => 140 })
          pdf.move_down 16
          pdf.table [[self.drawee[:name]]], TABLE_DEFAULTS
          pdf.table [[self.instructions[0]]], TABLE_DEFAULTS
          rows = []
          if self.descriptions
            self.descriptions.each { |description| rows << [description] }
            pdf.table rows, TABLE_DEFAULTS.merge(:vertical_padding => 1)
          end

          # Bank Compensation Form
          pdf.text self.typeable_line(@barcode), :at => [190, 335], :size => 12
          pdf.y = 350
          pdf.table [[self.payment_text, self.due_on.to_s_br ]], TABLE_DEFAULTS.merge(:widths => { 0 => 450 } )
          pdf.table [[self.transferor, "#{self.agency}/#{self.account}-#{self.account_cd}" ]], TABLE_DEFAULTS.merge(:widths => { 0 => 450 } )
          pdf.table [
            [
              self.documented_at.to_s_br,
              self.document_number,
              self.document_specie,
              self.need_acceptation,
              self.processed_at.to_s_br,
              "#{self.portfolio}/#{self.our_number}-#{self.calculate_our_number_cd}"
            ]
          ], TABLE_DEFAULTS.merge(:widths => { 0 => 100, 1 => 100, 2 => 80, 3 => 40, 4 => 100 } )
          pdf.table [["", self.portfolio, self.currency_symbol, self.quantity, self.value.to_currency, (self.quantity * self.value).to_currency]], TABLE_DEFAULTS.merge(:widths => { 0 => 100, 1 => 100, 2 => 80, 3 => 40, 4 => 100 } )
          y  = 210
          self.instructions.each do |instruction|
            pdf.text instruction, :at => [5, y]
            y -= pdf.font.height
          end
          pdf.text self.drawee[:name], :at => [5, 116]
          pdf.text self.drawee[:address1], :at => [5, 106]
          pdf.text self.drawee[:address2], :at => [5, 96]
          # end with barcode
          my_barcode = Barby::Code25Interleaved.new(@barcode)
          my_barcode.annotate_pdf(pdf, { :height => 30, :y => -20, :x => 0, :xdim => 0.8 })
        end

        private

          TABLE_DEFAULTS = {
            :position => :left,
            :font_size => 8,
            :border_width => 0,
            :align => :left,
            :vertical_padding => 6
          }

      end # Bradesco
    end # end Bank
  end # end KillBill
end