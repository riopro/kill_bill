require File.dirname(__FILE__) + '/../../spec_helper'

describe "Includes" do

  describe "Date" do
    describe ".due_day_factor" do
      [
        ["2000-07-03", 1000],
        ["2000-07-05", 1002],
        ["2002-05-01", 1667],
        ["2010-11-17", 4789],
        ["2025-02-21", 9999],
      ].each do |date_test, value_expected|
        it "should return #{value_expected} for #{date_test}" do
          date_test.to_date.due_day_factor.should == value_expected
        end
      end
      [
        ["2000-07-03", 1001],
        ["2000-07-05", 2222],
      ].each do |date_test, value_expected|
        it "should not return #{value_expected} for #{date_test}" do
          date_test.to_date.due_day_factor.should_not == value_expected
        end
      end
    end
  end
end