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
    
end
