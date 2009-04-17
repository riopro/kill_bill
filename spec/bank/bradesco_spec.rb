require File.dirname(__FILE__) + '/../spec_helper'

describe Riopro::KillBill::Bank::Bradesco do
  before(:each) do
    global_stubs
  end
  describe "Validations" do
    before(:each) do
      @bank_bradesco = Riopro::KillBill::Bank::Bradesco.new
    end
    describe "for account attribute" do
      [12345678, 23456789].each do |variable|
        it "should not succed for #{variable}" do
          lambda {
            @bank_bradesco.account = variable
          }.should raise_error(ArgumentError)
        end
      end
      [123, 1234, 1234567, 2345678].each do |variable|
        it "should succed for #{variable}" do
          @bank_bradesco.account = variable
          @bank_bradesco.account.length.should == 7
        end
      end
    end
    describe "for our_number attribute" do
      [123456789012, 12234343433434343, 2232432535546567].each do |variable|
        it "should not succed for #{variable}" do
          lambda {
            @bank_bradesco.our_number = variable
          }.should raise_error(ArgumentError)
        end
      end
      [123, 1234, 1234567, 2345678, 1234567890].each do |variable|
        it "should succed for #{variable}" do
          @bank_bradesco.our_number = variable
          @bank_bradesco.our_number.length.should == 11
        end
      end
    end
  end
  describe "Instance methods" do
    before(:each) do
      @bank_bradesco = Riopro::KillBill::Bank::Bradesco.new
      @bank_bradesco.agency = "0607"
      @bank_bradesco.account = "15255"
      @bank_bradesco.our_number = "12345678"
    end
    describe "process_options" do
      it "should assign variables from option" do
        options = { :account => "0567", :our_number => "12345678", :transferor => "RIOPRO" }
        @bank_bradesco = Riopro::KillBill::Bank::Bradesco.new(options)
        @bank_bradesco.account.should == "0000567"
        @bank_bradesco.our_number.should == "00012345678"
        @bank_bradesco.transferor.should == options[:transferor]
      end
    end
#    describe "pdf_parameters" do
#      before(:each) do
#        @bank_bradesco.due_on = Date.today
#        @bank_bradesco.instructions = ["teste"]
#        @bank_bradesco.drawee = { :name => 'otavio', :address1 => "minha rua", :address2 => "rio de janeiro" }
#        @font = mock(Prawn::Document, { :size= => "10", :height => 10 })
#        @pdf = mock(Prawn::Document, { :table => "table", :font =>  @font, :move_down => "10", :y= => "", :text => "" })
#        @barby_barcode = mock(Barby::Code25Interleaved, { :annotate_pdf => "" })
#        Barby::Code25Interleaved.stub!(:new).and_return(@barby_barcode)
#      end
#      it "should call barcode method" do
#        @bank_bradesco.should_receive(:barcode).and_return("01234567890123456789012345678901234567891234")
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it 'should receive billing typeable line' do
#        bill_bar_code_data = "01234567890123456789012345678901234567891234"
#        @bank_bradesco.stub!(:barcode).and_return(bill_bar_code_data)
#        @bank_bradesco.should_receive(:typeable_line).with(bill_bar_code_data).and_return("000")
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it "should call Barby barcode method" do
#        @barby_barcode.should_receive(:annotate_pdf).and_return("bar code")
#        Barby::Code25Interleaved.should_receive(:new).and_return(@barby_barcode)
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it "should place drawee name and address" do
#        @bank_bradesco.should_receive(:drawee).exactly(4).and_return("otavio")
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it "should place value" do
#        @bank_bradesco.should_receive(:value).exactly(4).and_return(100.0)
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it "should place instructions" do
#        @bank_bradesco.should_receive(:instructions).exactly(2).and_return([""])
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#      it "should place our number" do
#        @bank_bradesco.stub!(:barcode).and_return("0000")
#        @bank_bradesco.should_receive(:our_number).exactly(4).and_return("22222")
#        @bank_bradesco.pdf_parameters(@pdf)
#      end
#    end
#
    describe "calculate_account_cd" do
      before(:each) do
        @bank_bradesco.agency = "1234"
        @bank_bradesco.account = "56789"
      end
      it "should call module10" do
        @bank_bradesco.should_receive(:module10).with("#{@bank_bradesco.agency}#{@bank_bradesco.account}").and_return(1)
        @bank_bradesco.calculate_account_cd.should == 1
      end
    end

    describe "calculate_our_number_cd" do
      before(:each) do
        @bank_bradesco.portfolio = "09"
      end
      describe "portfolio 09" do
        it "should call module11_2to7" do
          @bank_bradesco.should_receive(:module11_2to7).with("#{@bank_bradesco.portfolio}#{@bank_bradesco.our_number}").and_return(1)
          @bank_bradesco.calculate_our_number_cd.should == 1
        end
        [
          ["02", "90960000533", 8],
          ["02", "90700000300", 2],
          ["02", "90840000416", 0],
          ["02", "90510000304", "P"],
          ["19", "00000000002", 8],
          ["19", "00000000001", "P"],
          ["19", "00000000006", 0],
        ].each do |portfolio, our_number, cd|
          it "should return #{cd} as check digit for #{our_number} and portfolio #{portfolio}" do
            @bank_bradesco.portfolio = portfolio
            @bank_bradesco.our_number = our_number
            @bank_bradesco.calculate_our_number_cd.should == cd
          end
        end
      end
    end

    describe "barcode" do
      before(:each) do
        @bank_bradesco.due_on = Date.new(2008,3,12)
      end
      it "should build barcode correctly" do
        @bank_bradesco.barcode.should == "23794380900000000000607090001234567800152550"

        @bank_bradesco.value = 135.00
        @bank_bradesco.due_on = Date.new(2004,9,3)
        @bank_bradesco.agency = "0810"
        @bank_bradesco.account = "53678"
        @bank_bradesco.our_number = "258281"
        @bank_bradesco.barcode.should == "23799252300000135000810090000025828100536780"
        @bank_bradesco.calculate_barcode_cd.should == 9
        @bank_bradesco.build_barcode.should == "2379252300000135000810090000025828100536780"
        @bank_bradesco.barcode.should == "23799252300000135000810090000025828100536780"

        @bank_bradesco.our_number = "10281"
        @bank_bradesco.barcode.should == "23791252300000135000810090000001028100536780"
      end
      it "should try to format our_number and value with zeros at left" do
        @bank_bradesco.our_number = "12345678"
        @bank_bradesco.value = 1.35
        @bank_bradesco.should_receive(:zeros_at_left).with(@bank_bradesco.value, 10).and_return("0000000135")
        @bank_bradesco.barcode
      end
      it "should calculate due day factor" do
        @bank_bradesco.due_on.should_receive(:due_day_factor).and_return(1203)
        @bank_bradesco.barcode
      end
      it "should calculate account_cd" do
        @bank_bradesco.should_receive(:calculate_account_cd).and_return(1)
        @bank_bradesco.barcode
      end
    end
  end
end