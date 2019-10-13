# frozen_string_literal: true
require 'html/pipeline'

HTML::Pipeline.require_dependency('commonmarker', 'MarkdownTranslationFilter')

class MarkdownTranslationFilter < HTML::Pipeline::TextFilter
  def initialize(text, context = nil, result = nil)
    super text, context, result
    @parser = context[:markdown_parser].new
  end

  def call
    extensions = context.fetch(
      :commonmarker_extensions,
      %i[table strikethrough tagfilter autolink]
    )

    parse_options = :DEFAULT
    parse_options = [:UNSAFE] if context[:unsafe]

    doc = CommonMarker.render_doc(@text, parse_options, extensions)

    changes = []
    doc.each do |node|
      if @parser.respond_to?(node.type)
        changes << @parser.send(node.type, node)
      end
    end

    changes.each do |original, replacement|
      @text = @text.sub(original, replacement)
    end

    @text
  end
end

class HeaderRenderer
  def header(node)
    original = node.to_commonmark(:DEFAULT, -1).chomp
    inner = ''
    node.each { |child| inner += child.to_html }
    replacement = "<h#{node.header_level} id=\"foo\">#{inner}</h#{node.header_level}>"
    [original, replacement]
  end
end
