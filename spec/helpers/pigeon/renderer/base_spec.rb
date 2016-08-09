require 'spec_helper'

module Pigeon
  module Renderer
    describe "Base" do
      before(:each) do
        @renderer = Base.new
      end

      it "should render an empty vector" do
        expect(@renderer.render([])).to eq('')
      end

      it "should render empty tags" do
        expect(@renderer.render(["p"])).to eq("<p></p>")
        expect(@renderer.render(["br"])).to eq("<br />")
      end

      it "should render tags with content text" do
        expect(@renderer.render(["h1", "Title"])).to eq("<h1>Title</h1>")
        expect(@renderer.render(["h2", "Hello", "World"])).
          to eq("<h2>HelloWorld</h2>")
      end

      it "should optionally accept an attributes hash" do
        expect(@renderer.render(["span", { :class => 'foo' }, "with class foo"])).
          to eq("<span class=\"foo\">with class foo</span>")
        expect(@renderer.render(["p", { :class => 'bar' }])).
          to eq("<p class=\"bar\"></p>")
        expect(@renderer.render(["hr", { :class => 'bar' }])).
          to eq("<hr class=\"bar\" />")
      end

      it "should recursively render content elements" do
        expect(@renderer.render(["div", ["h1", "Title"], ["p", "Foo", ["br"], "Bar"]])).
          to eq("<div><h1>Title</h1><p>Foo<br />Bar</p></div>")
      end

      it "should parse tag name to produce element IDs" do
        expect(@renderer.render(["div#foo"])).to eq("<div id=\"foo\"></div>")
      end

      it "should parse tag name to produce classes" do
        expect(@renderer.render(["div.foo"])).to eq("<div class=\"foo\"></div>")
        expect(@renderer.render(["div.foo.bar"])).
          to eq("<div class=\"foo bar\"></div>")
      end

      it "should accept IDs and classes simultaneously and in any order" do
        expect(@renderer.render(["div#foo.bar.baz"])).
          to match(/<div (?=.*id="foo")(?=.*class="bar baz").*/)
        expect(@renderer.render(["div.bar#foo.baz"])).
          to match(/<div (?=.*id="foo")(?=.*class="bar baz").*/)
        expect(@renderer.render(["div.bar.baz#foo"])).
          to match(/<div (?=.*id="foo")(?=.*class="bar baz").*/)
      end

      it "should render DIVs by default" do
        expect(@renderer.render(["#foo"])).to eq("<div id=\"foo\"></div>")
        expect(@renderer.render([".foo"])).to eq("<div class=\"foo\"></div>")
      end

      it "should merge options from the tag and the given hash" do
        expect(@renderer.render(["#foo", { :class => "bar" }])).
          to match(/<div (?=.*id="foo")(?=.*class="bar").*/)
        expect(@renderer.render([".foo", { :id => "bar" }])).
          to match(/<div (?=.*class="foo")(?=.*id="bar").*/)
        expect(@renderer.render([".foo", { :class => "bar" }])).
          to match(/<div (?=.*class="foo bar").*/)
        expect(@renderer.render(["#foo", { :id => "bar" }])).
          to match(/<div (?=.*id="foo").*/)
      end

      it "should not render unknown at-commands by default" do
        expect(@renderer.render(["@x", "foo"])).to eq('')
      end

      it "should delegate at-command rendering" do
        class TestRenderer < Base
          def render_at_command(v)
            safe_join(v)
          end
        end

        @renderer = TestRenderer.new
        expect(@renderer.render(["@x", "foo"])).to eq('@xfoo')
      end

      it "should escape HTML entities by default" do
        expect(@renderer.render(["h1", "<b>foo</b>"])).not_to have_tag('b')
      end

      it "should accept @raw command and not escape entities" do
        expect(@renderer.render(["@raw", "<b>foo</b>"])).to have_tag('b')
      end

      it "should accept @template, @wizard and @page commands" do
        expect(@renderer.render(["@template"])).to have_tag('div', with: { 'class' => 'pigeon pigeon_template' })
        expect(@renderer.render(["@wizard"])).to have_tag('div', with: { 'class' => 'pigeon pigeon_wizard' })
        expect(@renderer.render(["@page"])).to have_tag('div', with: { 'class' => 'pigeon_wizard_page' })
      end

      it "should prefix custom options with 'data-' in template commands" do
        expect(@renderer.render(["@template", { "foo" => 42 }])).to have_tag('div', with: { "data-foo" => 42 })
      end
    end
  end
end

