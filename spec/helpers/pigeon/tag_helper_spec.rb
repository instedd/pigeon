require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the TagHelper. For example:
#
# describe TagHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
module Pigeon
  describe TagHelper do
    describe "pigeon_schema_options" do
      before(:each) do
        @schemas = NuntiumChannel.schemas
      end

      it "returns a list of schemas appropiate for options_for_select" do
        options = helper.pigeon_schema_options(@schemas)
        options.count.should eq(@schemas.count)
        options.all? { |o| 
          o.respond_to?(:first) && o.respond_to?(:last) 
        }.should be_true
      end

      it "prefixes values with given string" do
        options = helper.pigeon_schema_options(@schemas, 'foo/')
        options.all? { |o|
          o.last.starts_with? 'foo/'
        }.should be_true
      end
    end
  end
end
