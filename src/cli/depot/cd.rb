#
# Fizzy command to show configuration details.
#
class Fizzy::CLI::Cd < Fizzy::CLI::Command
  def initialize
    super("Change directory to the configuration directory.",
          spec: Fizzy::CLI.known_args(:fizzy_dir, :cfg_name))
  end

  def run
    paths    = compute_paths
    dir_path = paths.cur_cfg || paths.cfg
    change_dir(dir_path)
    inform_user(dir_path)
  end

  #
  # Compute the paths of interest.
  #
  private def compute_paths
    prepare_storage(options[:fizzy_dir],
                    valid_meta:   false,
                    valid_inst:   false,
                    valid_cfg:    !options[:cfg_name].nil? && :readonly,
                    cur_cfg_name: options[:cfg_name])
  end

  #
  # Change directory to the provided path, spawning a new sub-shell.
  #
  private def change_dir(dir_path)
    info "Changing directory to #{✏ dir_path}."
    FileUtils.cd(dir_path)
    system(get_env!(:SHELL))
  end

  #
  # Inform user about the change of directory.
  #
  private def inform_user(dir_path)
    success "CD done in #{✏ dir_path}."
  end
end
