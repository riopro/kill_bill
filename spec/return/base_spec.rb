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
  
end
