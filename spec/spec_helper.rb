$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'
require 'kill_bill'
require 'date'
require "active_support"

def global_stubs
  Date.stub!(:current).and_return(Date.today)
end