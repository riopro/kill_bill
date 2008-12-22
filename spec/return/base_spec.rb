require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Return::Base do
  
  before(:each) do
    File.stub!(:exist?).and_return(true)
    #File.stub!(:readlines).and_return(@fake_file_array)
    
    #@base = Riopro::KillBill::Return::Base.new('/path/to/file')
  end
  
  describe "initialization" do
    it "should raise an error if the return file is not found" do
      File.should_receive(:exist?).with('/wrong/path/to/file').and_return(false)
      lambda {
        Riopro::KillBill::Return::Base.new('/wrong/path/to/file')
      }.should raise_error
    end
    
  end

  describe "Sample file test" do
    before(:each) do
      @return_file = Riopro::KillBill::Return::Base.auto_initialize('./spec/return/../../examples/sample_data/retorno_itau_teste.ret')
    end
    it "should return a Return::Itau class" do
      @return_file.class.to_s.should == "Riopro::KillBill::Return::Itau"
    end
    it "should load a hash with the header" do
      @return_file.header.is_a?(Hash).should be_true
    end
    it "should load a hash with the trailer" do
      @return_file.trailer.is_a?(Hash).should be_true
    end
    it "should load an Array of transactions" do
      @return_file.transactions.is_a?(Array).should be_true
    end
    it "should load 2 transactions" do
      @return_file.transactions.size.should == 2
    end
  end
  
end
