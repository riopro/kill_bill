require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Return::Itau do
  
    before(:each) do
      @fake_file_array = [
        'A' * 400, # header
        'B' * 400, # transaction 1
        'C' * 400, # transaction 2
        'D' * 400  # trailer
      ]
    end

    describe "Sample file test" do
      before(:each) do
        @return_file = Riopro::KillBill::Return::Itau.new('./spec/return/../../examples/sample_data/retorno_itau_teste.ret', true)
      end
      describe "header" do
        it "should contain the agency" do
          @return_file.header[:agencia].should == "0567"
        end
        it "should contain the account" do
          @return_file.header[:conta].should == "15346"
        end
      end
    end
    
end
