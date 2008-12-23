module Riopro
  module KillBill
    module Return
      class Itau < Riopro::KillBill::Return::Base
        
        private
        
          # Parses the header line and returns a hash.
          def parse_header(string)
            {
              # identificação do registro header
              :tipo_registro => string[0..0].to_i,
              # identificação do arquivo retorno
              :codigo_retorno => string[1..1],
              # identificação por extenso do tipo de movimento
              :literal_retorno => string[2..8],
              # identificação do tipo de serviço
              :codigo_servico => string[9..10],
              # identificação por extenso do tipo de serviço
              :literal_servico => string[11..25],
              # agência mantenedora da conta
              :agencia => string[26..29],
              # complemento de registro
              :zeros => string[30..31],
              # número da conta corrente da empresa
              :conta => string[32..36],
              # dígito de auto-conferência ag/conta empresa
              :dac => string[37..37],
              # complemento do registro
              #:brancos1 => string[38..45],
              # nome por extenso da "empresa mãe"
              :nome_empresa => string[46..75],
              # número do banco na câmara de compensação
              :codigo_banco => string[76..78],
              # nome por extenso do banco cobrador
              :nome_banco => string[79..93].strip,
              # data de geração do arquivo
              :data_geracao => string[94..99],
              # unidade de densidade
              :densidade => string[100..104],
              # densidade de gravação do arquivo
              :unidade_densidade => string[105..107],
              # número sequencial do arquivo retorno
              :numero_sequencial_arquivo_retorno => string[108..112],
              # data de crédito dos lançamentos
              :data_credito => string[113..118],
              # complemento do registro
              #:brancos2 => string[119..393],
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
              # identificação do tipo de serviço
              :codigo_servico => string[2..3],
              # identificação do banco na compensação
              :codigo_banco => string[4..6],
              # complemento de registro
              #:brancos1 => string[7..16],
              # quantidade de títulos em cobrança simples
              :quantidade_titulos_simples => string[17..24].to_i,
              # valor total dos títulos em cobrança simples
              :valor_total_simples => string[25..38].to_f/100,
              # referência do aviso bancário
              :aviso_bancario_simples => string[39..46],
              # complemento do registro
              #:brancos2  => string[47..56],
              # quantidade de títulos em cobrança/vinculada
              :quantidade_titulos_vinculada => string[57..64].to_i,
              # valor total dos títulos em cobrança/vinculada
              :valor_total_vinculada => string[65..78].to_f/100,
              # referência do aviso bancário
              :aviso_bancario_vinculada => string[79..86],
              # complemento do registro
              #:brancos3  => string[87..176],
              # quantidade de títulos em cobrança direta/escritural
              :quantidade_titulos_direta => string[177..184].to_i,
              # valor total dos títulos em cobrança direta/escritural
              :valor_total_direta => string[185..198],
              # referência do aviso bancário
              :aviso_bancario_direta => string[199..206],
              # número sequencial do arquivo retorno
              :controle_arquivo => string[207..211],
              # quantidade de registros de transação
              :quantidade_detalhes => string[212..219].to_i,
              # valor dos títulos informados no arquivo
              :valor_total_informado => string[220..233].to_f/100,
              # complemento do registro
              #:brancos4 => string[234..393],
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
              :codigo_inscricao => string[1..2],
              # número de inscrição da empresa (cpf/cnpj)
              :numero_inscricao => string[3..16],
              # agência mantenedora da conta
              :agencia => string[17..20],
              # complemento de registro
              :zeros => string[21..22],
              # número da conta corrente da empresa
              :conta => string[23..27],
              # dígito de auto-conferência ag/conta empresa
              :dac => string[28..28],
              # complemento de registro
              #:brancos1 => string[29..36],
              # identificação do título na empresa
              :uso_da_empresa => string[37..61],
              # identificação do título no banco
              :nosso_numero1 => string[62..69],
              # complemento de registro
              #:brancos2 => string[70..81],
              # número da carteira
              :carteira1 => string[82..84],
              # identificação do título no banco
              :nosso_numero2 => string[85..92],
              # dac do nosso número
              :dac_nosso_numero => string[93..93],
              # complemento de registro
              #:brancos3 => string[94..106],
              # código da carteira
              :carteira2 => string[107..107],
              # identificação da ocorrência
              :codigo_ocorrencia => string[108..109],
              # data de de ocorrência no banco
              :data_ocorrencia => convert_date(string[110..115]),
              # número do documento de cobrança (dupl, np etc)
              :numero_documento => string[116..125],
              # confirmação do número do título no banco
              :nosso_numero3 => string[126..133],
              # complemento de registro
              #:brancos4 => string[134..145],
              # data de vencimento do título
              :vencimento => convert_date(string[146..151]),
              # valor nominal do título
              :valor_titulo => string[152..164].to_f / 100,
              # número do banco na câmara de compensação
              :codigo_banco => string[165..167],
              # ag. cobradora, ag. de liquidação ou baixa
              :agencia_cobradora => string[168..171],
              # dac da agência cobradora
              :dac_agencia_cobradora => string[172..172],
              # espécie do título
              :especie => string[173..174],
              # valor da despesa de cobrança
              :tarifa_cobranca => string[175..187].to_f / 100,
              # complemento de registro
              #:brancos5 => string[188..213],
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
              :instrucao_cancelada => string[301..304],
              # complemento de registro
              #:brancos7 => string[305..323],
              # nome do sacado
              :nome_sacado => string[324..353],
              # complemento de registro
              #:brancos8 => string[354..376],
              # registros rejeitados ou alegação do sacado
              :erros => string[377..384],
              # complemento de registro
              #:brancos9 => string[385..391],
              # meio pelo qual o título foi liquidado
              :codigo_liquidacao => string[392..393],
              # número sequencial do registro no arquivo
              :numero_sequencial => string[394..399].to_i
            }
          end
        
      end
    end
  end
end