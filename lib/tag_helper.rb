require 'set'

module TagHelper
  BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                       autoplay controls loop selected hidden scoped async
                       defer reversed ismap seemless muted required
                       autofocus novalidate formnovalidate open).to_set
  BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attribute| attribute.to_sym })

  # Returns an empty HTML tag of type +name+ which by default is XHTML
  # compliant. Set +open+ to true to create an open tag compatible
  # with HTML 4.0 and below. Add HTML attributes by passing an attributes
  # hash to +options+. Set +escape+ to false to disable attribute value
  # escaping.
  #
  # ==== Options
  # The +options+ hash is used with attributes with no value like (<tt>disabled</tt> and
  # <tt>readonly</tt>), which you can give a value of true in the +options+ hash. You can use
  # symbols or strings for the attribute names.
  #
  # ==== Examples
  #   tag("br")
  #   # => <br />
  #
  #   tag("br", nil, true)
  #   # => <br>
  #
  #   tag("input", { :type => 'text', :disabled => true })
  #   # => <input type="text" disabled="disabled" />
  #
  #   tag("img", { :src => "open & shut.png" })
  #   # => <img src="open &amp; shut.png" />
  #
  #   tag("img", { :src => "open &amp; shut.png" }, false, false)
  #   # => <img src="open &amp; shut.png" />
  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
  end

  # Returns an HTML block tag of type +name+ surrounding the +content+. Add
  # HTML attributes by passing an attributes hash to +options+.
  # Instead of passing the content as an argument, you can also use a block
  # in which case, you pass your +options+ as the second parameter.
  # Set escape to false to disable attribute value escaping.
  #
  # ==== Options
  # The +options+ hash is used with attributes with no value like (<tt>disabled</tt> and
  # <tt>readonly</tt>), which you can give a value of true in the +options+ hash. You can use
  # symbols or strings for the attribute names.
  #
  # ==== Examples
  #   content_tag(:p, "Hello world!")
  #    # => <p>Hello world!</p>
  #   content_tag(:div, content_tag(:p, "Hello world!"), :class => "strong")
  #    # => <div class="strong"><p>Hello world!</p></div>
  #   content_tag("select", options, :multiple => true)
  #    # => <select multiple="multiple">...options...</select>
  #
  #   <%= content_tag :div, :class => "strong" do -%>
  #     Hello world!
  #   <% end -%>
  #    # => <div class="strong">Hello world!</div>
  def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    if block_given?
      options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
      content_tag_string(name, capture(&block), options, escape)
    else
      content_tag_string(name, content_or_options_with_block, options, escape)
    end
  end

  private

    def content_tag_string(name, content, options, escape = true)
      tag_options = tag_options(options, escape) if options
      "<#{name}#{tag_options}>#{escape ? ERB::Util.h(content) : content}</#{name}>".html_safe
    end

    def tag_options(options, escape = true)
      unless options.blank?
        attrs = []
        options.each_pair do |key, value|
          if BOOLEAN_ATTRIBUTES.include?(key)
            attrs << %(#{key}="#{key}") if value
          elsif !value.nil?
            final_value = value.is_a?(Array) ? value.join(" ") : value
            final_value = html_escape(final_value) if escape
            attrs << %(#{key}="#{final_value}")
          end
        end
        " #{attrs.sort * ' '}".html_safe unless attrs.empty?
      end
    end
end

include TagHelper
