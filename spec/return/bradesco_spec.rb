require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Return::Bradesco do

    describe "Sample file test" do
      before(:each) do
        @return_file = Riopro::KillBill::Return::Bradesco.new('./spec/return/../../examples/sample_data/retorno_bradesco_teste.ret', true)
      end
      describe "header" do
        it "should not be nil" do
          @return_file.header.should_not be_nil
        end
        it "should be an Bradesco return type" do
          @return_file.header[:codigo_banco].should == "237"
          @return_file.header[:nome_banco].should == "Bradesco"
        end
        it "should have a date of creation" do
          @return_file.header[:data_geracao].should == "2009-04-20".to_date
        end
       it "should have a date of credit" do
          @return_file.header[:data_credito].should == "2009-04-19".to_date
        end
        it "should contain the company code" do
          @return_file.header[:codigo_empresa].should == "123456789012345"
        end
        it "should contain the company name" do
          @return_file.header[:razao_social].should == "EMPRESA DE TESTE PARA KILLBILL"
        end
        it "should be a return type" do
          @return_file.header[:literal_retorno].should == "Retorno"
        end
        it "should have register type = 0" do
          @return_file.header[:tipo_registro].should == 0
        end
        it "should have sequence number" do
          @return_file.header[:numero_sequencial].should == "000001"
        end
      end
#      describe "transaction" do
#        before(:each) do
#          @transaction = @return_file.transactions[0]
#        end
#        it "should be an Bradesco return type" do
#          @transaction[:codigo_banco].should == "237"
#        end
#        it "should have register type = 1" do
#          @transaction[:tipo_registro].should == 1
#        end
#        it "should have agency, account, our number and portfolio" do
#          @transaction[:carteira1].should == "175"
#          @transaction[:agencia].should == "0567"
#          @transaction[:conta].should == "15346"
#          @transaction[:nosso_numero1].should == "00123456"
#          @transaction[:nosso_numero2].should == "00123456"
#          @transaction[:dac_nosso_numero].should == "5"
#        end
#        it "should parse and retrieve the correct values" do
#          @transaction[:valor_titulo].should == 45.5
#          @transaction[:tarifa_cobranca].should == 1.23
#          @transaction[:valor_abatimento].should == 0.0
#          @transaction[:valor_principal].should == 49.11
#          @transaction[:juros_mora_multa].should == 3.61
#        end
#        it "should parse and retrieve the correct dates" do
#          @transaction[:vencimento].to_s.should == '2007-07-10'
#          @transaction[:data_ocorrencia].to_s.should == '2007-10-23'
#          @transaction[:data_credito].to_s.should == '2007-10-22'
#        end
#      end
#      describe "trailer" do
#        before(:each) do
#          @trailer = @return_file.trailer
#        end
#        it "should have register type = 9" do
#          @trailer[:tipo_registro].should == 9
#        end
#        it "should be an Bradesco return type" do
#          @trailer[:codigo_banco].should == "237"
#        end
#        it "should returns the correct quantity of transactions" do
#          @trailer[:quantidade_detalhes].should == 2
#        end
#        it "should returns the correct transactions sum" do
#          @trailer[:valor_total_informado].should == 97.36
#        end
#      end
#
#      describe "valid?" do
#        it "should be true using test file" do
#          @return_file.valid?.should be_true
#          @return_file.errors.should be_empty
#        end
#        it "should not be true if quantidade_detalhes is incorrect" do
#          @return_file.transactions.size.should == 2
#          @return_file.trailer[:quantidade_detalhes] = 3
#          @return_file.valid?.should be_false
#          @return_file.errors.should_not be_empty
#          @return_file.errors.size.should == 1
#        end
#        it "should not be true if valor_total_informado is incorrect" do
#          @return_file.transactions.size.should == 2
#          @return_file.trailer[:valor_total_informado] = 10.0
#          @return_file.valid?.should be_false
#          @return_file.errors.should_not be_empty
#          @return_file.errors.size.should == 1
#        end
#      end
    end
    
end
