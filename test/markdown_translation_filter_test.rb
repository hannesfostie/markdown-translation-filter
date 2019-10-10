# frozen_string_literal: true
require 'test_helper'

class MarkdownTranslationFilterTest < Minitest::Test
  def pipeline
    HTML::Pipeline.new [
      MarkdownTranslationFilter
    ], { markdown_parser: HeaderRenderer }
  end

  def test_it_works
    assert_equal "hello", pipeline.call("hello")[:output].chomp
  end

  def test_it_renders_header_as_html
    # current solution does not properly render children of a node, in this
    # case, <em>
    md = "## Foo bar *baz*"
    assert_equal '<h2 id="foo-bar-baz">Foo bar baz</h2>', pipeline.call(md)[:output].chomp
  end

  def test_it_doesnt_add_weird_linebreaks
    # current solution adds a weird linebreak in the middle of the alt text
    md = '![Diagram illustrating logplex sources and drains](https://devcenter1.assets.heroku.com/article-images/1521584374-logplex-sources-and-drains.png)'
    assert_equal md, pipeline.call(md)[:output].chomp
  end

  def test_it_doesnt_rewrite_commonmark_style
    # current solution replaces an unordered list with asterisks with one using spaces and
    # dashes
    # other examples include rewriting ``` codeblocks to indented codeblocks
    md = "This is a list:\n\n* foo\n* bar"
    assert_equal md, pipeline.call(md)[:output].chomp
  end

  def test_it_doesnt_rewrite_callouts
    # current solution removes newlines where it thinks one isn't needed
    md = ">callout\n>The Heroku CLI requires **Git**, the popular version control system."
    assert_equal md, pipeline.call(md)[:output].chomp
  end
end
