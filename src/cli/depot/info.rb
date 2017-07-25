#
# Fizzy command to show configuration details.
#
class Fizzy::CLI::Info < Fizzy::CLI::Command
  def initialize
    super("info", "Show configuration details.",
          spec: Fizzy::CLI.known_args(:fizzy_dir, :cfg_name))
  end

  def run
    # Prepare paths before considering details.
    paths = prepare_storage(options[:fizzy_dir],
                            valid_meta:   false,
                            valid_cfg:    :readonly,
                            valid_inst:   false,
                            cur_cfg_name: options[:cfg_name])

    # Print details.
    tell("{c{Available variable files:}}")
    avail_vars(paths.cur_cfg_vars).each do |path|
      name = path.basename(path.extname)
      tell("\t→ {m{#{name}}}")
    end
  end
end
