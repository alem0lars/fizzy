#
# Fizzy command to show fizzy version.
#
class Fizzy::CLI::Cleanup < Fizzy::CLI::Command
  def initialize
    super("Cleanup the fizzy storage.",
          spec: Fizzy::CLI.known_args(:fizzy_dir))
  end

  def run
    # Prepare paths for cleanup.
    paths = prepare_storage(options[:fizzy_dir],
                            valid_meta: false,
                            valid_cfg:  false,
                            valid_inst: false)

    # Perform cleanup.
    status =
      if ask "Remove the fizzy root directory (#{✏ paths.root})"
        paths.root.rmtree
      end

    inform_user(status, paths.root)
  end

  private

    #
    # Inform user about the cleanup status.
    #
    def inform_user(status, root_dir)
      case status
      when true  then success "{g{Successfully cleaned: #{✏ root_dir}.}}"
      when false then error "Failed to cleanup: #{✏ root_dir}."
      when nil   then warning "Cleanup skipped.", ask_continue: false
      end
    end
end
