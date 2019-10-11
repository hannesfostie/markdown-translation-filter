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

    text = ''
    doc.each do |node|
      if @parser.respond_to?(node.type)
        text += @parser.send(node.type, node)
      elsif node.type == :document
        next
      else
        text += "#{node.to_commonmark(:DEFAULT, -1)}"
      end
    end

    text
  end
end

class HeaderRenderer #< CommonMarker::HtmlRenderer
  def header(node)
    inner = ''
    node.each { |child| inner += child.to_html }
    "<h#{node.header_level} id=\"foo\">#{inner}</h#{node.header_level}>\n"
  end
end
