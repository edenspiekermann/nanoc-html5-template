module AssetTagHelper
  def javascript_include_tag(*sources)
    options = sources.extract_options!.stringify_keys
    sources.collect { |source| javascript_src_tag(source, options) }.join("\n").html_safe
  end

  def javascript_src_tag(source, options)
    content_tag("script", "", { "type" => 'text/javascript', "src" => javascript_path(source)}.merge(options))
  end

  private

  def javascript_path(source)
    if is_uri?(source)
      source
    else
      "/javascripts/#{source}.js"
    end
  end

  def is_uri?(path)
    path =~ %r{^[-a-z]+://|^cid:}
  end

end

include AssetTagHelper
