require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Bank::Base do
  before(:each) do
    global_stubs
    @base = Riopro::KillBill::Bank::Base.new
  end
  describe "Validations" do
    describe "for drawee attribute" do
      it "should fail when is not a correct Hash" do
        ["a string", nil, 1, 1.0, {}].each do |variable|
          lambda {
            @base.drawee = variable
          }.should raise_error(ArgumentError)
        end
      end
      it "should succed if is an Hash with the correct attributes" do
        [
          {:name => "otavio", :address1 => "Rua Tal", :address2 => "Rio de Janeiro"},
          {:name => "", :address1 => "", :address2 => ""},
          {:name => "otavio"}
        ].each do |variable|
          @base.drawee = variable
        end
      end
    end
    describe "for instructions attribute" do
      it "should fail when is not a non empty Array" do
        ["a string", nil, 1, 1.0, {}, []].each do |variable|
          lambda {
            @base.instructions = variable
          }.should raise_error(ArgumentError)
        end
      end
      it "should succed if is an Hash with the correct attributes" do
        [
          [""],
          ["testing", "test"]
        ].each do |variable|
          @base.instructions = variable
        end
      end
    end
  end
  describe "Instance methods" do
    describe "module10" do
      [ 
        ["001905009", 5],
        ["4014481606", 9],
        ["0680935031", 4],
        ["29004590", 5],
        ["0607", 2],
        ["060715255", 0],
        ["154785547", 6],
        ["154710207", 7],
        ["081153678", 8]
      ].each do |value, response|
        it "should return #{response} for #{value}" do
          @base.module10(value).should == response
        end
      end
      [ "06se07", "stere", "s00002323", "034043040s", "0054-454", "2323#434", nil ].each do |value|
        it "should not calculate check digit for #{value}" do
          @base.module10(value).should == nil
        end
      end
      it "should return FixNum for correct input values" do
        response = @base.module10("03432423607")
        response.class.should == Fixnum
      end
    end
    
    describe "module11_2to9" do

      [ 
        ["0019373700000001000500940144816060680935031", 3],
        ["060715255", 9],
        ["154785547", 6],
        ["154710207", 9],
        ["081153678", 5]
      ].each do |value, response|
        it "should return #{response} for #{value}" do
          @base.module11_2to9(value).should == response
        end
      end
      [ "06se07", "stere", "s00002323", "034043040s", "0054-454", "2323#434", nil ].each do |value|
        it "should not calculate check digit for #{value}" do
          @base.module11_2to9(value).should == nil
        end
      end
      it "should return FixNum for correct input values" do
        response = @base.module11_2to9("03432423607")
        response.class.should == Fixnum
      end
    end

    describe "module11_9to2" do

      [
        ["85068014982", 9],
        ["05009401448", 1],
        ["12387987777700168", 2],
        ["4042", 8],
        ["61900", 0],
        ["0719", 6],
        ["000000005444", 5],
        ["5444", 5],
        ["01129004590", 3]
      ].each do |value, response|
        it "should return #{response} for #{value}" do
          @base.module11_9to2(value).should == response
        end
      end
      [ "06se07", "stere", "s00002323", "034043040s", "0054-454", "2323#434", nil ].each do |value|
        it "should not calculate check digit for #{value}" do
          @base.module11_9to2(value).should == nil
        end
      end
      it "should return FixNum for correct input values" do
        response = @base.module11_9to2("03432423607")
        response.class.should == Fixnum
      end
    end

    describe "zeros_at_left" do
      [
        [123.0, 10, "0000012300"],
        [123.53, 10, "0000012353"],
        [0.53, 5, "00053"],
        ["123", 8, "00000123"],
        [1234567.89, 8, "123456789"]
      ].each do |value, size, response|
        it "should return #{response} for #{value} and size #{size}" do
          @base.zeros_at_left(value, size).should == response
        end
      end
      ["", "   ", 1234].each do |value|
        it "should return #{value} for #{value}" do
          @base.zeros_at_left(value).should == value
        end
      end
      [ Date.today, nil ].each do |value|
        it "should raise an error for #{value}" do
          lambda {
            @base.zeros_at_left(value).should == nil
          }.should raise_error(NoMethodError)
        end
      end
    end

    describe "digit_sum" do
      [
        [111, 3],
        [123, 6],
        [8, 8],
        [1234567, 28],
        [0, 0]
      ].each do |value, response|
        it "should return #{response} for #{value}" do
          @base.digits_sum(value).should == response
        end
      end
      [ Date.today, "123", "8", 11.0, 1223454.0, nil ].each do |value|
        it "should return nil for #{value}" do
          @base.digits_sum(value).should == nil
        end
      end
    end

    describe "calculate_barcode_cd" do
      before(:each) do
        @base.stub!(:build_barcode).and_return("060715255")
      end
      it "should calculate_barcode_cd" do
        @base.calculate_barcode_cd.should == 9
      end
      it "should expect call build_barcode" do
        @base.should_receive(:build_barcode).and_return("060715255")
        @base.calculate_barcode_cd
      end
    end

    describe "process_options" do
      before(:each) do
        @options = { :value => 1.0, :account => "123456"}
      end
      it "should set instance methods values" do
        @base.process_options(@options)
        @base.value.should == @options[:value]
        @base.account.should == @options[:account]
      end
    end

    describe "typeable_line" do
      [
        ["00192376900000135000000001238798777770016818", "00190.00009 01238.798779 77700.168188 2 37690000013500"],
        ["49998371700000045502015722000000000041352106", "49992.01579 22000.000004 00413.521063 8 37170000004550"],
        ["40991393100002335670408071203522119648609408", "40990.40802 71203.522116 96486.094087 1 39310000233567"],
        ["34193392900003070141125133115412938160419000", "34191.12515 33115.412935 81604.190009 3 39290000307014"],
        ["39995392900010000001661015778904540639667001", "39991.66105 15778.904548 06396.670017 5 39290001000000"]
      ].each do |barcode, response|
        it "should return #{response} for #{barcode}" do
          @base.typeable_line(barcode).should == response
        end
      end
      [ 
        "122332435436554654654",
        "1234567890123456789012345678901234567890",
        "1234567890123456789012345678901234567890123r",
        "r1234567890123456789012345678901234567890123",
        "1234567890R123456789012345678901234567890123",
        "1234567890-123456789012345678901234567890123",
        "1234567890-123456789012345678901234567890+23",
        "1234567890-123456789012345678901234567$%@+23",
        "1234567890-12345678901234!*78901234567$%@+23",
        "123",
        "8",
        11.0,
        1223454.0,
        nil
      ].each do |barcode|
        it "should return nil for #{barcode}" do
          @base.typeable_line(barcode).should == nil
        end
      end
    end

    describe "to_pdf" do
      before(:each) do
        @pdf = mock(Prawn::Document)
        Prawn::Document.stub!(:new).and_return(@pdf)
        @pdf.stub!(:render)
        @base.stub!(:pdf_parameters).and_return(true)
        @base.bank = "bank_name"
      end
      it "should try to create the pdf object with background" do
        # Prawn::Document.should_receive(:new).with(:background => "./spec/bank/../../lib/bank/../images/#{@base.bank}.jpg").and_return(@pdf)
        Prawn::Document.should_receive(:new).and_return(@pdf)
        @base.to_pdf
      end
      it "should try to render the pdf file" do
        @pdf.should_receive(:render).and_return(true)
        @base.to_pdf
      end
      it "should try to place the bank image as background" do
        @base.should_receive(:bank).and_return("bank_name")
        @base.to_pdf
      end
      it "should call pdf_parameters method" do
        @base.should_receive(:pdf_parameters).with(@pdf)
        @base.to_pdf
      end
    end

    describe "to_pdf_file" do
      before(:each) do
        @pdf = mock(Prawn::Document)
        Prawn::Document.stub!(:generate).and_yield(@pdf)
        @pdf.stub!(:render)
        @base.stub!(:pdf_parameters).and_return(true)
        @base.bank = "bank_name"
        @file_name = "name_of_the_file"
      end
      it "should try to generate the pdf file with background" do
        # Prawn::Document.should_receive(:generate).with(@file_name, :background => "./spec/bank/../../lib/bank/../images/#{@base.bank}.jpg").and_return(@pdf)
        Prawn::Document.should_receive(:generate).and_return(@pdf)
        @base.to_pdf_file(@file_name)
      end
      it "should try to place the bank image as background" do
        @base.should_receive(:bank).and_return("bank_name")
        @base.to_pdf_file(@file_name)
      end
      it "should call pdf_parameters method" do
        @base.should_receive(:pdf_parameters).with(@pdf)
        @base.to_pdf_file @file_name
      end
    end
  end


end