#
# Fizzy command to sync configuration.
#
class Fizzy::CLI::Sync < Fizzy::CLI::Command
  def initialize
    super("Synchronize configuration.",
          spec: Fizzy::CLI.known_args(:fizzy_dir, :cfg_name,
                                      cfg_url: { required: false }))
  end

  def run
    paths = compute_paths
    sync_result = perform_sync(paths.cur_cfg)
    inform_user(sync_result, paths.cur_cfg)
  end

  private

  def compute_paths
    prepare_storage(options[:fizzy_dir],
                    valid_meta:   false,
                    valid_cfg:    false,
                    valid_inst:   false,
                    cur_cfg_name: options[:cfg_name])
  end

  def perform_sync(cur_cfg_path)
    Fizzy::Sync.perform(cur_cfg_path, options[:cfg_url])
  end

  #
  # Inform user about sync status.
  #
  def inform_user(sync_result, cur_cfg_path)
    if sync_result
      tell("{g{Synced to: `#{cur_cfg_path}`.}}")
    else
      error("Unable to sync.")
    end
  end
end
