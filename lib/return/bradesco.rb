module Riopro
  module KillBill
    module Return
      class Bradesco < Riopro::KillBill::Return::Base

        # Verifies if parsed file is valid. Returns boolean
        def valid?
          valid = true
          @errors = []
          unless self.transactions.size == self.trailer_total
            @errors << "Quantidade de transações diferente da quantidade total do Trailer do arquivo"
          end
          if self.transactions.size > 0
            total = 0.0
            self.transactions.each do |transaction|
              total += transaction[:valor_principal]
            end
            unless total == self.trailer[:valor_total_informado]
              @errors << "Valor total das transações diferente do existente no Trailer do arquivo"
            end
          end

          valid = false unless @errors.empty?

          valid
        end
        
        private

          # Sum quantities for all transactions types
          def trailer_total
            self.trailer[:quantidade_titulos_simples] +
              self.trailer[:quantidade_titulos_simples] +
              self.trailer[:quantidade_confirmacao_entrada] +
              self.trailer[:quantidade_registros_liquidados] +
              self.trailer[:quantidade_titulos_baixados] +
              self.trailer[:quantidade_abatimento_cancelado] +
              self.trailer[:quantidade_vencimento_alterado] +
              self.trailer[:quantidade_abatimento_concedido] +
              self.trailer[:quantidade_confirmacao_protesto] +
              self.trailer[:quantidade_rateios_efetuados]
          end
        
          # Parses the header line and returns a hash.
          def parse_header(string)
            {
              # identificação do registro header (conteúdo 0)
              :tipo_registro => string[0..0].to_i,
              # identificação do arquivo retorno
              :codigo_retorno => string[1..1],
              # identificação por extenso do tipo de movimento
              :literal_retorno => string[2..8],
              # identificação do tipo de serviço
              :codigo_servico => string[9..10],
              # identificação por extenso do tipo de serviço
              :literal_servico => string[11..25],
              # código da empresa no bradesco
              :codigo_empresa => string[26..45].strip,
              # razão social da empresa
              :razao_social => string[46..75],
              # número do banco na câmara de compensação
              :codigo_banco => string[76..78],
              # nome por extenso do banco cobrador
              :nome_banco => string[79..93].strip,
              # data de geração do arquivo
              :data_geracao => convert_date(string[94..99]),
              # brancos
              #:brancos1 => string[100..107],
              # número aviso bancário
              :numero_aviso_bancario => string[108..112],
              # brancos
              #:brancos2 => string[113..378],
              # data de crédito dos lançamentos
              :data_credito => convert_date(string[379..384]),
              # brancos
              #:brancos3 => string[385..393],
              # número sequencial do registro no arquivo
              :numero_sequencial => string[394..399]
            }
          end
          
          # Parses the trailer line and returns a hash.
          def parse_trailer(string)
            {
              # identificação do registro trailer
              :tipo_registro => string[0..0].to_i,
              # identificação de arquivo retorno
              :codigo_retorno => string[1..1],
              # identificação do tipo de registro (01)
              :codigo_servico => string[2..3],
              # identificação do banco na compensação
              :codigo_banco => string[4..6],
              # complemento de registro
              #:brancos1 => string[7..16],
              # quantidade de títulos em cobrança simples
              :quantidade_titulos_simples => string[17..24].to_i,
              # valor total dos títulos em cobrança simples
              :valor_total_simples => string[25..38].to_f/100,
              # numero referência do aviso bancário
              :aviso_bancario_simples => string[39..46],
              # complemento do registro
              #:brancos2  => string[47..56],
              # quantidade registros ocorrência 02 - confirmação entradas
              :quantidade_confirmacao_entrada => string[57..61].to_i,
              # valor total registros ocorrência 02 - confirmação entradas
              :valor_total_confirmacao_entrada => string[62..73].to_f/100,
              # valor total registros ocorrência 06 - liquidação
              :valor_total_registros_liquidados => string[74..85].to_f/100,
              # quantidade registros ocorrência 06 - liquidação
              :quantidade_registros_liquidados => string[86..90].to_i,
              # Campo duplicado? repete logo acima no arquivo
              # :valor_total_registros_liquidados => string[91..102].to_f/100,
              # quantidade registros ocorrência 09 e 10 - títulos baixados
              :quantidade_titulos_baixados => string[103..107].to_i,
              # valor total registros ocorrência 09 e 10 - títulos baixados
              :valor_total_titulos_baixados => string[108..119].to_f/100,
              # quantidade registros ocorrência 13 - abatimento cancelado
              :quantidade_abatimento_cancelado => string[120..124].to_i,
              # valor total registros ocorrência 13 - abatimento cancelado
              :valor_total_abatimento_cancelado => string[125..136].to_f/100,
              # quantidade registros ocorrência 14 - vencimento alterado
              :quantidade_vencimento_alterado => string[137..141].to_i,
              # valor total registros ocorrência 14 - vencimento alterado
              :valor_total_vencimento_alterado => string[142..153].to_f/100,
              # quantidade registros ocorrência 12 - abatimento concedido
              :quantidade_abatimento_concedido => string[154..158].to_i,
              # valor total registros ocorrência 12 - abatimento concedido
              :valor_total_abatimento_concedido => string[159..170].to_f/100,
              # quantidade registros ocorrência 19 - confirmação da instrução de protesto
              :quantidade_confirmacao_protesto => string[171..175].to_i,
              # valor total registros ocorrência 19 - confirmação da instrução de protesto
              :valor_total_confirmacao_protesto => string[176..187].to_f/100,
              # brancos
              #:brancos3  => string[188..361],
              # valor total rateios efetuados
              :valor_total_rateios_efetuados => string[362..376].to_f/100,
              # quantidade rateios efetuados
              :quantidade_rateios_efetuados => string[377..384].to_i,
              # brancos
              #:brancos4  => string[385..393],
              # número sequencial do registro no arquivo
              :numero_sequencial => string[394..399].to_i
            }
          end
          
          # Parses a transaction line and returns a hash.
          def parse_transaction(string)
            {
              # identificação do registro transação
              :tipo_registro => string[0..0].to_i,
              # identificação do tipo de inscrição/empresa
              # (01-CPF; 02-CNPJ; 03-PIS/PASEP;98-não tem;99-Outros)
              :codigo_inscricao => string[1..2],
              # número de inscrição da empresa (cpf/cnpj)
              :numero_inscricao => string[3..16],
              # brancos
              #:brancos1 => string[17..19],
              #:zero => string[20..20],
              # carteira de boletos
              :carteira => string[21..22],
              # agência
              :agencia => string[23..27],
              # dígito da agência
              :agencia_cd => string[28..28],
              # conta corrente
              :conta_corrente => string[29..35],
              # dígito conta corrente
              :conta_corrente_cd => string[36..36],
              # identificação do título na empresa
              :uso_da_empresa => string[37..61],
              # zeros
              #:zeros1 => string[62..69],
              # identificação do título no banco
              :nosso_numero => string[70..81],
              # complemento de registro
              #:brancos2 => string[82..91],
              # zeros
              #:zeros2 => string[92..103],
              # Somente será informado “R” ou branco
              :indicador_rateio => string[104..104],
              # zeros
              #:zeros3 => string[105..106],
              # código da carteira
              :carteira2 => string[107..107],
              # identificação da ocorrência
              :codigo_ocorrencia => string[108..109],
              # data de de ocorrência no banco
              :data_ocorrencia => convert_date(string[110..115]),
              # número do documento de cobrança (dupl, np etc)
              :numero_documento => string[116..125],
              # confirmação do número do título no banco
              :nosso_numero3 => string[126..145],
              # data de vencimento do titulo
              :vencimento => convert_date(string[146..151]),
              # valor nominal do título
              :valor_titulo => string[152..164].to_f / 100,
              # número do banco na câmara de compensação
              :codigo_banco_cobrador => string[165..167],
              # ag. cobradora, ag. de liquidação ou baixa
              :agencia_cobradora => string[168..172],
              # espécie do título
              :especie => string[173..174],
              # valor da despesa de cobrança
              # para os códigos de ocorrência (:codigo_ocorrencia)
              # 02 - Entrada Confirmada
              # 28 - Débito de tarifas
              :tarifa_cobranca => string[175..187].to_f / 100,
              # outras despesas / custos de protesto
              :outras_despesas_custos => string[188..200].to_f / 100,
              # outras despesas / custos de protesto
              # não será informado
              #:juros_operacao_atraso => string[201..213].to_f / 100,
              # valor do iof a ser recolhido (notas seguro)
              :valor_iof => string[214..226].to_f / 100,
              # valor do abatimento concedido
              :valor_abatimento => string[227..239].to_f / 100,
              # valor do desconto concedido
              :descontos => string[240..252].to_f / 100,
              # valor lançado em conta corrente
              :valor_principal => string[253..265].to_f / 100,
              # valor de mora e multa pagos pelo sacado
              :juros_mora_multa => string[266..278].to_f / 100,
              # valor de outros créditos
              :outros_creditos => string[279..291].to_f / 100,
              # complemento de registro
              #:brancos6 => string[292..294],
              # data de crédito desta liquidação
              :data_credito => convert_date(string[295..300]),
              # código da instrução cancelada
              :origem_pagamento => string[301..303],
              # complemento de registro
              #:brancos7 => string[304..317],
              # motivo de rejeição (para :codigo_ocorrencia)
              :motivo_rejeicao => string[318..327],
              # brancos
              #:brancos8 => string[328..367],
              # número cartório
              :numero_cartorio => string[368..369],
              #
              :numero_protocolo => string[370..379],
              # brancos
              #:brancos9 => string[380..393],
              # número sequencial do registro no arquivo
              :numero_sequencial => string[394..399].to_i
            }
          end
        
      end
    end
  end
end