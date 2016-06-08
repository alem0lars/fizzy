module Fizzy::Vars
  class Setup

    include Fizzy::IO
    include Fizzy::Filesystem

    def initialize(vars_dir_path, name, bindings)
      @binding = bindings
      @vars_dir_path = vars_dir_path
      @name          = name
    end

    # Setup the variables that will be used during ERB processing.
    #
    # Those variables will be set into an instance field called `@vars`.
    #
    # After calling this method, you can directly access the variables using
    # `@vars` or using the attribute reader `vars`.
    #
    def run
      setup_vars(@vars_dir_path, @name)
    end

  protected

    def setup_vars(vars_dir_path, name)
      fmt, content = read_vars(vars_dir_path, name)
      error("Invalid vars: `#{name}`.") if fmt == nil || content == nil
      self_vars    = parse_vars(name, fmt, content)
      parents      = parse_parents_vars(fmt, content)
      parents_vars = merge_parents_vars(vars_dir_path, parents)
      merge_with_parents_vars(self_vars, parents_vars)
    end

    def read_vars(vars_dir_path, name)
      yaml_file_path = find_yaml_path(vars_dir_path.join(name)) unless vars_dir_path.nil? || name.nil?

      if yaml_file_path
        [:yaml, File.read(yaml_file_path)]
      elsif !name.nil? && ENV.has_key?(name)
        [:json, ENV[name]]
      else
        [nil, nil]
      end
    end

    def parse_vars(name, fmt, content)
      content = ERB.new(content).result(@binding)
      case fmt
        when :yaml
          begin
            YAML.load(content) || {}
          rescue Psych::SyntaxError => e
            error("Invalid syntax in YAML `#{name}`: #{e.message}")
          end
        when :json
          begin
            JSON.parse(content)
          rescue JSON::JSONError => e
            error("Invalid JSON `#{name}`: #{e.message}.")
          end
        else error("Unrecognized format: `#{fmt}`")
      end
    end

    def parse_parents_vars(fmt, content)
      parents_regexp = case fmt
                         when :yaml then Fizzy::CFG.vars.yaml_regexp
                         when :json then Fizzy::CFG.vars.json_regexp
                         else       error("Unrecognized format: `#{fmt}`.")
                       end
      if md = content.match(parents_regexp)
        md[:parents].split(",")
                    .map(&:strip)
                    .reject{|p| p =~ Fizzy::CFG.vars.parent_dummy_regexp}
      else
        []
      end
    end

    def merge_with_parents_vars(self_vars, parents_vars)
      parents_vars.deep_merge(self_vars)
    end

    def merge_parents_vars(vars_dir_path, parents)
      parents.inject([]) do |acc, parent| # Vars for each parent.
        parent_vars = setup_vars(vars_dir_path, parent)
        acc << parent_vars
      end.inject({}) do |acc, parent_vars| # Merge them.
        acc.deep_merge(parent_vars)
      end
    end

  end
end
