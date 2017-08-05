#
# Fizzy command to edit configuration.
#
class Fizzy::CLI::Edit < Fizzy::CLI::Command
  def initialize
    super("Find the files relative to PATTERN and edit them.",
          spec: Fizzy::CLI.known_args(:fizzy_dir, :cfg_name).merge(
            pattern: {
              desc: "Pattern to find files to be edited",
              abbrev: "P",
              required: true
            }
          ))
  end

  def run
    # Prepare stuff for editing.
    paths = compute_paths
    find_path = (paths.cur_cfg || paths.cfg).join(options[:pattern])
    cfg_files = find_cfg_files(find_path)
    cfg_files_arg = build_cfg_files_arg(cfg_files)
    status = perform_edit(cfg_files_arg)
    inform_user(status, cfg_files_arg)
  end

  private

  def compute_paths
    prepare_storage(options[:fizzy_dir],
                    valid_meta:   false,
                    valid_inst:   false,
                    cur_cfg_name: options[:cfg_name])
  end

  #
  # Find configuration files to be edited.
  #
  def find_cfg_files(find_path)
    if find_path.exist?
      Array[find_path]
    else
      Pathname.glob("#{find_path}*", File::FNM_DOTMATCH).to_a
              .select(&:file?)
              .reject { |path| path.to_s =~ /\.git/ }
    end
  end

  def build_cfg_files_arg(cfg_files)
    cfg_files.collect(&:shell_escape) .join(" ") .strip
  end

  #
  # Perform edit.
  #
  def perform_edit(cfg_files_arg)
    if cfg_files_arg.empty?
      warning("No files matching `#{options[:cfg_name]}` have been found.",
              ask_continue: false)
      nil
    else
      tell("{c{Editing configuration file(s): `#{cfg_files_arg}`.}}")
      system("#{Fizzy::CFG.editor} #{cfg_files_arg}")
    end
  end

  #
  # Inform user about the editing status.
  #
  def inform_user(status, cfg_files_arg)
    case status
    when true  then tell("{g{Successfully edited: `#{cfg_files_arg}`.}}")
    when false then error("Failed to edit: `#{cfg_files_arg}`.", :red)
    when nil   then warning("Editing skipped.", ask_continue: false)
    end
  end
end
