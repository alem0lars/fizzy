module Fizzy
end
module Fizzy::ANSIColors

  class << self
    def default_open_tag_regexp
      /(\{(?<color_spec>[lrgybmcwLRGYBMCW]+)\{)/
    end

    def default_close_tag_regexp
      /(\}\})/
    end

    def colorize(str, open_tag_regexp: nil, close_tag_regexp: nil)
      open_tag_regexp = default_open_tag_regexp if open_tag_regexp.nil?
      close_tag_regexp = default_close_tag_regexp if close_tag_regexp.nil?

      tree = TreeBuilder.new(open_tag_regexp, close_tag_regexp).build(str)

      colorized_str = str.dup
      escapes_size = 0
      tree.visit do |node|
        if node.is_a?(StartTagNode)
          color_escape = Fizzy::ANSIColors.spec_to_color(node.color_spec)
        elsif node.is_a?(EndTagNode)
          color_escape = Fizzy::ANSIColors.spec_to_color(node.parent.color_spec)
        end
        colorized_str.insert(escapes_size + node.end_idx, color_escape)
        escapes_size += color_escape.length
      end
      colorized_str.gsub!(open_tag_regexp, "")
      colorized_str.gsub!(close_tag_regexp, "")
      colorized_str
    end

    # Convert a color specification to an ansi color escape.
    #
    # * Upcase is for background colors
    # * Downcase is for foreground colors
    #
    def spec_to_color(color_spec)
      names = {
        l: :black,
        r: :red,
        g: :green,
        y: :yellow,
        b: :blue,
        m: :magenta,
        c: :cyan,
        w: :white
      }

      if color_spec.nil?
        ""
      else
        color_spec = color_spec.to_s
        color_name = names[color_spec.downcase.to_sym]

        if color_spec == "CLEAR"
          Fizzy::ANSIColors.clear_colors
        else
          if color_spec == color_spec.upcase # background color
            Fizzy::ANSIColors.bg_colors[color_name]
          else # foreground color
            Fizzy::ANSIColors.fg_colors[color_name]
          end
        end
      end
    end
  end

  class TreeBuilder
    def initialize(open_tag_regexp, close_tag_regexp)
      @open_tag_regexp = open_tag_regexp
      @close_tag_regexp = close_tag_regexp
    end

    def build(str)
      start_tag_nodes = str.to_enum(:scan, @open_tag_regexp).map do
        m = Regexp.last_match
        StartTagNode.new(m.begin(0), m.end(0), m[0].length, m[:color_spec])
      end

      end_tag_nodes = str.to_enum(:scan, @close_tag_regexp).map do
        m = Regexp.last_match
        EndTagNode.new(m.begin(0), m.end(0), m[0].length)
      end

      tag_nodes = (start_tag_nodes + end_tag_nodes).sort

      root_node = StartTagNode.new(0, 0, 0, :CLEAR)

      parent_node = root_node
      previous_node = root_node
      tag_nodes.each do |current_node|
        if previous_node.is_a?(StartTagNode) && current_node.is_a?(StartTagNode)
          parent_node = previous_node
        end
        if previous_node.is_a?(EndTagNode) && current_node.is_a?(EndTagNode)
          parent_node = parent_node.parent
        end
        current_node.parent = parent_node
        parent_node.children.push(current_node)
        previous_node = current_node
      end

      # Add the end tag for the root node.
      final_node = EndTagNode.new(str.length, str.length, 0)
      final_node.parent = root_node
      root_node.children.push(final_node)

      return root_node
    end
  end

  class Node
    attr_accessor :parent, :children
    attr_reader :start_idx, :end_idx, :size

    include Comparable

    def initialize(start_idx, end_idx, size)
      @parent = nil
      @children = []
      @start_idx = start_idx
      @end_idx = end_idx
      @size = size
    end

    def <=>(another)
      self.start_idx <=> another.start_idx
    end

    def visit(&block)
      yield(self)
      children.each {|c| c.visit(&block)}
    end

    def to_pretty_str(indent_lvl=0, include_children: true)
      "#{"\t" * indent_lvl}#{self.class.name}(#{to_fields_str(indent_lvl, include_children)})"
    end

    def to_fields_str(indent_lvl, include_children)
      indent_str = "#{"\t" * indent_lvl}"
      if children.empty? || !include_children
        children_str = ""
      else
        children_str = "children="
        children_str = "\n#{indent_str}[\n"
        children_str += children.map do |c|
          c.to_pretty_str(indent_lvl + 1, include_children: include_children)
        end.join("\n")
        children_str += "\n#{indent_str}]"
      end
      "start_idx=`#{start_idx}` end_idx=`#{end_idx}` size=`#{size}`#{children_str}"
    end
    protected :to_fields_str
  end

  class StartTagNode < Node
    attr_reader :color_spec

    def initialize(start_idx, end_idx, size, color_spec)
      super(start_idx, end_idx, size)
      @color_spec = color_spec
    end

    def to_fields_str(indent_lvl, include_children)
      "color_spec=`#{color_spec}` #{super}"
    end
    protected :to_fields_str
  end

  class EndTagNode < Node
  end

  # ─────────────────────────────────────────────────────── Colors definition ──

  class << self

    # Definition of ANSI foreground colors.
    #
    def fg_colors
      {
        black: "\e[30m",
        red: "\e[31m",
        green: "\e[32m",
        yellow: "\e[33m",
        blue: "\e[34m",
        magenta: "\e[35m",
        cyan: "\e[36m",
        white: "\e[37m"
      }
    end

    # Definition of ANSI background colors.
    #
    def bg_colors
      {
        black: "\e[40m",
        red: "\e[41m",
        green: "\e[42m",
        yellow: "\e[43m",
        blue: "\e[44m",
        magenta: "\e[45m",
        cyan: "\e[46m",
        white: "\e[47m"
      }
    end

    def clear_colors
      "\e[0m"
    end

  end

end

# TEST

# TODO move to the specs
input = "{b{gogo{r{the quick {g{brown fox {y{jumps over}} the {m{lazy}} dog}} the {c{quick}} brown fox jumps}}}} over the {g{lazy}} dog"
actual = Fizzy::ANSIColors.colorize(input)
expected = "\e[0m\e[34mgogo\e[31mthe quick \e[32mbrown fox \e[33mjumps over\e[32m the \e[35mlazy\e[32m dog\e[31m the \e[36mquick\e[31m brown fox jumps\e[34m\e[0m over the \e[32mlazy\e[0m dog\e[0m"
puts actual == expected
