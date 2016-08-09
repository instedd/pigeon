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
        expect(options.count).to eq(@schemas.count)
        expect(options.all? { |o| 
          o.respond_to?(:first) && o.respond_to?(:last) 
        }).to be_truthy
      end

      it "prefixes values with given string" do
        options = helper.pigeon_schema_options(@schemas, 'foo/')
        expect(options.all? { |o|
          o.last.starts_with? 'foo/'
        }).to be_truthy
      end
    end
  end
end
