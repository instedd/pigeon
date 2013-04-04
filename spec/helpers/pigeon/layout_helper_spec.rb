require 'spec_helper'

module Pigeon
  describe LayoutHelper do
    describe "pigeon_render_vector" do
      it "should accept an empty vector" do
        helper.pigeon_render_vector([]).should eq('')
      end

      it "should render empty tags" do
        helper.pigeon_render_vector(["p"]).should eq("<p></p>")
        helper.pigeon_render_vector(["br"]).should eq("<br />")
      end

      it "should render tags with content text" do
        helper.pigeon_render_vector(["h1", "Title"]).should eq("<h1>Title</h1>")
        helper.pigeon_render_vector(["h2", "Hello", "World"]).
          should eq("<h2>HelloWorld</h2>")
      end

      it "should optionally accept an attributes hash" do
        helper.pigeon_render_vector(["span", { :class => 'foo' }, "with class foo"]).
          should eq("<span class=\"foo\">with class foo</span>")
        helper.pigeon_render_vector(["p", { :class => 'bar' }]).
          should eq("<p class=\"bar\"></p>")
        helper.pigeon_render_vector(["img", { src: 'bar.png' }]).
          should eq("<img src=\"bar.png\" />")
      end

      it "should recursively render content elements" do
        helper.pigeon_render_vector(["div", ["h1", "Title"], ["p", "Foo", ["br"], "Bar"]]).
          should eq("<div><h1>Title</h1><p>Foo<br />Bar</p></div>")
      end

      it "should parse tag name to produce element IDs" do
        helper.pigeon_render_vector(["div#foo"]).should eq("<div id=\"foo\"></div>")
      end

      it "should parse tag name to produce classes" do
        helper.pigeon_render_vector(["div.foo"]).should eq("<div class=\"foo\"></div>")
        helper.pigeon_render_vector(["div.foo.bar"]).
          should eq("<div class=\"foo bar\"></div>")
      end

      it "should accept IDs and classes simultaneously and in any order" do
        helper.pigeon_render_vector(["div#foo.bar.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        helper.pigeon_render_vector(["div.bar#foo.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        helper.pigeon_render_vector(["div.bar.baz#foo"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
      end

      it "should render DIVs by default" do
        helper.pigeon_render_vector(["#foo"]).should eq("<div id=\"foo\"></div>")
        helper.pigeon_render_vector([".foo"]).should eq("<div class=\"foo\"></div>")
      end

      it "should merge options from the tag and the given hash" do
        helper.pigeon_render_vector(["#foo", { :class => "bar" }]).
          should eq("<div class=\"bar\" id=\"foo\"></div>")
        helper.pigeon_render_vector([".foo", { :id => "bar" }]).
          should eq("<div class=\"foo\" id=\"bar\"></div>")
        helper.pigeon_render_vector([".foo", { :class => "bar" }]).
          should eq("<div class=\"foo bar\"></div>")
        helper.pigeon_render_vector(["#foo", { :id => "bar" }]).
          should eq("<div id=\"foo\"></div>")
      end

      it "should return an empty string for at-commands if no delegate is given" do
        helper.pigeon_render_vector(["@f", "foo"]).should eq('')
      end

      it "should delegate at-commands to the given block" do
        helper.pigeon_render_vector(["@f", "foo", "bar"]) do |args|
          args.should eq(["@f", "foo", "bar"])
        end
      end
    end

    describe "pigeon_field_name" do
      it "should nest the field name if given a scope" do
        helper.pigeon_field_name('foo').should eq('foo')
        helper.pigeon_field_name('foo', 'bar').should eq('bar[foo]')
        helper.pigeon_field_name('foo', 'bar[baz]').should eq('bar[baz][foo]')
      end
    end

    describe "pigeon_render_attribute_field" do
      it "should render string attributes" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="text"/)
      end

      it "should render password attributes" do
        @attr = ChannelAttribute.new 'foo', :password
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="password"/)
      end

      it "should render integer attributes" do
        @attr = ChannelAttribute.new 'foo', :integer
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="number"/)
      end

      it "should render enum attributes" do
        @attr = ChannelAttribute.new 'foo', :enum
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<select.*name="foo"/)
      end

      it "should render timezone attributes" do
        @attr = ChannelAttribute.new 'foo', :timezone
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<select.*name="foo"/)
      end

      it "should render boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="checkbox".*<label for="foo"/)
      end
    end
  end
end

