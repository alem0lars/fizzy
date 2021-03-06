#
# Fizzy command to show fizzy version.
#
class Fizzy::CLI::Cleanup < Fizzy::CLI::Command
  def initialize
    super("Cleanup the fizzy storage.",
          spec: Fizzy::CLI.known_args(:fizzy_dir))
  end

  def run
    paths  = compute_paths
    status = perform_cleanup
    inform_user(status, paths.root)
  end

  #
  # Compute the paths of interest.
  #
  private def compute_paths
    paths = prepare_storage(options[:fizzy_dir],
                            valid_meta: false,
                            valid_cfg:  false,
                            valid_inst: false)
  end

  #
  # Cleanup all fizzy's related files.
  #
  private def perform_cleanup
    # TODO implement different cleanups:
    # 1. Remove both instantiation output and installation output
    # 2. Remove just installation output
    # Allow to select which config (defaults to all) should be cleaned up

    if ask "Remove the fizzy root directory (#{✏ paths.root})"
      paths.root.rmtree
    end
  end

  #
  # Inform user about the cleanup status.
  #
  private def inform_user(status, root_dir)
    case status
    when true  then success "Successfully cleaned #{✏ root_dir}."
    when false then error "Failed to cleanup #{✏ root_dir}."
    when nil   then warning "Cleanup skipped.", ask_continue: false
    end
  end
end
