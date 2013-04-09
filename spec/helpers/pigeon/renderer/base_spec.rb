require 'spec_helper'

module Pigeon
  module Renderer
    describe "Base" do
      before(:each) do
        @renderer = Base.new
      end

      it "should render an empty vector" do
        @renderer.render([]).should eq('')
      end

      it "should render empty tags" do
        @renderer.render(["p"]).should eq("<p></p>")
        @renderer.render(["br"]).should eq("<br />")
      end

      it "should render tags with content text" do
        @renderer.render(["h1", "Title"]).should eq("<h1>Title</h1>")
        @renderer.render(["h2", "Hello", "World"]).
          should eq("<h2>HelloWorld</h2>")
      end

      it "should optionally accept an attributes hash" do
        @renderer.render(["span", { :class => 'foo' }, "with class foo"]).
          should eq("<span class=\"foo\">with class foo</span>")
        @renderer.render(["p", { :class => 'bar' }]).
          should eq("<p class=\"bar\"></p>")
        @renderer.render(["hr", { :class => 'bar' }]).
          should eq("<hr class=\"bar\" />")
      end

      it "should recursively render content elements" do
        @renderer.render(["div", ["h1", "Title"], ["p", "Foo", ["br"], "Bar"]]).
          should eq("<div><h1>Title</h1><p>Foo<br />Bar</p></div>")
      end

      it "should parse tag name to produce element IDs" do
        @renderer.render(["div#foo"]).should eq("<div id=\"foo\"></div>")
      end

      it "should parse tag name to produce classes" do
        @renderer.render(["div.foo"]).should eq("<div class=\"foo\"></div>")
        @renderer.render(["div.foo.bar"]).
          should eq("<div class=\"foo bar\"></div>")
      end

      it "should accept IDs and classes simultaneously and in any order" do
        @renderer.render(["div#foo.bar.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        @renderer.render(["div.bar#foo.baz"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
        @renderer.render(["div.bar.baz#foo"]).
          should eq("<div class=\"bar baz\" id=\"foo\"></div>")
      end

      it "should render DIVs by default" do
        @renderer.render(["#foo"]).should eq("<div id=\"foo\"></div>")
        @renderer.render([".foo"]).should eq("<div class=\"foo\"></div>")
      end

      it "should merge options from the tag and the given hash" do
        @renderer.render(["#foo", { :class => "bar" }]).
          should eq("<div class=\"bar\" id=\"foo\"></div>")
        @renderer.render([".foo", { :id => "bar" }]).
          should eq("<div class=\"foo\" id=\"bar\"></div>")
        @renderer.render([".foo", { :class => "bar" }]).
          should eq("<div class=\"foo bar\"></div>")
        @renderer.render(["#foo", { :id => "bar" }]).
          should eq("<div id=\"foo\"></div>")
      end

      it "should not render at-commands by default" do
        @renderer.render(["@x", "foo"]).should eq('')
      end

      it "should delegate at-command rendering" do
        class TestRenderer < Base
          def render_at_command(v)
            safe_join(v)
          end
        end

        @renderer = TestRenderer.new
        @renderer.render(["@x", "foo"]).should eq('@xfoo')
      end
    end
  end
end

