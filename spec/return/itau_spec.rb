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
      end
      describe "transaction" do
        it "should be an Itau return type" do
          @return_file.header[:codigo_banco].should == "341"
        end
      end
    end
    
end
