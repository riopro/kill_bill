require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Return::Itau do

    describe "Sample file test" do
      before(:each) do
        @return_file = Riopro::KillBill::Return::Itau.new('./spec/return/../../examples/sample_data/retorno_itau_teste.ret', true)
      end
      describe "header" do
        it "should be an Itau return type" do
          @return_file.header[:codigo_banco].should == "341"
          @return_file.header[:nome_banco].should == "BANCO ITAU SA"
        end
        it "should contain the agency" do
          @return_file.header[:agencia].should == "0567"
        end
        it "should contain the account" do
          @return_file.header[:conta].should == "15346"
        end
        it "should be a return type" do
          @return_file.header[:literal_retorno].should == "RETORNO"
        end
        it "should have register type = 0" do
          @return_file.header[:tipo_registro].should == "0"
        end
      end
      describe "transaction" do
        before(:each) do
          @transaction = @return_file.transactions[0]
        end
        it "should be an Itau return type" do
          @transaction[:codigo_banco].should == "341"
        end
        it "should have register type = 1" do
          @transaction[:tipo_registro].should == "1"
        end
        it "should have agency, account, our number and portfolio" do
          @transaction[:carteira1].should == "175"
          @transaction[:agencia].should == "0567"
          @transaction[:conta].should == "15346"
          @transaction[:nosso_numero1].should == "00123456"
          @transaction[:nosso_numero2].should == "00123456"
          @transaction[:dac_nosso_numero].should == "5"
        end
        it "should parse and retrieve the correct values" do
          @transaction[:valor_titulo].should == 45.5
          @transaction[:tarifa_cobranca].should == 1.23
          @transaction[:valor_abatimento].should == 0.0
          @transaction[:valor_principal].should == 49.11
          @transaction[:juros_mora_multa].should == 3.61
        end
      end
    end
    
end
