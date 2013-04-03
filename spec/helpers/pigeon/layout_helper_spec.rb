require 'spec_helper'

module Pigeon
  describe LayoutHelper do
    describe "render_vector" do
      it "should accept an empty vector" do
        helper.render_vector([]).should eq('')
      end

      it "should render empty tags" do
        helper.render_vector(["p"]).should eq("<p></p>")
        helper.render_vector(["br"]).should eq("<br />")
      end

      it "should render tags with content text" do
        helper.render_vector(["h1", "Title"]).should eq("<h1>Title</h1>")
        helper.render_vector(["h2", "Hello", "World"]).
          should eq("<h2>HelloWorld</h2>")
      end

      it "should optionally accept an attributes hash" do
        helper.render_vector(["span", { :class => 'foo' }, "with class foo"]).
          should eq("<span class=\"foo\">with class foo</span>")
        helper.render_vector(["p", { :class => 'bar' }]).
          should eq("<p class=\"bar\"></p>")
        helper.render_vector(["img", { src: 'bar.png' }]).
          should eq("<img src=\"bar.png\" />")
      end

      it "should recursively render content elements" do
        helper.render_vector(["div", ["h1", "Title"], ["p", "Foo", ["br"], "Bar"]]).
          should eq("<div><h1>Title</h1><p>Foo<br />Bar</p></div>")
      end

      it "should parse tag name to produce element IDs" do
        helper.render_vector(["div#foo"]).should eq("<div id=\"foo\"></div>")
      end

      it "should parse tag name to produce classes" do
        helper.render_vector(["div.foo"]).should eq("<div class=\"foo\"></div>")
        helper.render_vector(["div.foo.bar"]).
          should eq("<div class=\"foo bar\"></div>")
      end

      it "should accept IDs and classes simultaneously and in any order" do
        helper.render_vector(["div#foo.bar.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        helper.render_vector(["div.bar#foo.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        helper.render_vector(["div.bar.baz#foo"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
      end

      it "should render DIVs by default" do
        helper.render_vector(["#foo"]).should eq("<div id=\"foo\"></div>")
        helper.render_vector([".foo"]).should eq("<div class=\"foo\"></div>")
      end
    end
  end
end

