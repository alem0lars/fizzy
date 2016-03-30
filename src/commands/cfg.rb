class Fizzy::CfgCommand < Fizzy::BaseCommand

  def self.source_root
    "/"
  end

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name,  required: true))
  desc("details", "Show configuration details.")
  def details
    # Prepare paths before considering details.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta: false,
                            valid_inst: false,
                            cur_cfg_name: options.cfg_name,
                            readonly: true)
    # Print details.
    tell("Available variable files:", :cyan)
    avail_vars(paths.cur_cfg_vars).each do |path|
      name = path.basename(path.extname)
      tell("\t#{colorize(name, :magenta)}")
    end
  end

  method_option(*shared_option(:fizzy_dir))
  desc("cleanup", "Cleanup the fizzy storage.")
  def cleanup
    # Prepare paths for cleanup.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta: false,
                            valid_cfg:  false,
                            valid_inst: false)

    # Perform cleanup.
    status = exec_cmd("rm -Rf #{Shellwords.escape(paths.root)}") \
      if quiz("Do you want to remove the fizzy root directory `#{paths.root}`")

    # Inform user about the cleanup status.
    if status
      tell("Successfully cleaned: `#{paths.root}`.", :green)
    elsif status.nil?
      warning("Cleanup skipped.", ask_continue: false)
    else
      error("Failed to cleanup: `#{paths.root}`.", :red)
    end
  end

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name))
  desc("cd",
       "Change directory to the configuration directory " +
       "(useful for extensive filesystem manipulations).")
  def cd
    # Prepare stuff for changing directory.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta:   false,
                            valid_inst:   false,
                            valid_cfg:    !options.cfg_name.nil?,
                            cur_cfg_name: options.cfg_name)

    # Changing directory.
    dir_path = paths.cur_cfg || paths.cfg
    tell("Changing directory to: `#{dir_path}`.", :cyan)
    FileUtils.cd(dir_path)
    system(get_env!(:SHELL))

    # Inform user about the changing directory status.
    tell("CD done in: `#{dir_path}`.", :green)
  end

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name))
  desc("edit PATTERN", "Find the files relative to PATTERN and edit them.")
  def edit(pattern)
    # Prepare stuff for editing.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta:   false,
                            valid_inst:   false,
                            cur_cfg_name: options.cfg_name)
    find_path = (paths.cur_cfg || paths.cfg).join(pattern)
    cfg_files_arg = if find_path.exist?
                      Shellwords.escape(find_path)
                    else
                      Dir.glob("#{find_path}*", File::FNM_DOTMATCH).to_a.
                        delete_if { |path| path =~ /\.git/ }.
                        collect   { |path| Shellwords.escape(path) }.
                        join(" ")
                    end.strip

    # Perform edit.
    if cfg_files_arg.empty?
      warning("No files matching `#{cfg_name}` have been found.",
              ask_continue: false)
      status = nil
    else
      tell("Editing configuration file(s): `#{cfg_files_arg}`.", :cyan)
      status = system("#{Fizzy::CFG.editor} #{cfg_files_arg}")
    end

    # Inform user about the editing status.
    if status
      tell("Successfully edited: `#{cfg_files_arg}`.", :green)
    elsif status.nil?
      warning("Editing skipped.", ask_continue: false)
    else
      error("Failed to edit: `#{cfg_files_arg}`.", :red)
    end
  end

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name))
  method_option(*shared_option(:cfg_url))
  desc("sync", "Synchronize the remote repository with the local one.")
  def sync
    # Prepare stuff for syncing.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta:   false,
                            valid_cfg:    false,
                            valid_inst:   false,
                            cur_cfg_name: options.cfg_name)

    # Perform sync.
    sync_result = if paths.cur_cfg.directory?
      tell("Syncing from origin", :blue)
      status = nil
      FileUtils.cd(paths.cur_cfg) do
        # Perform fetch, because we need to know if there are remote changes,
        # so we need to know the updated remote commit hash.
        tell("Fetching informations from origin.", :cyan)
        status = git_fetch
        # (Optional) Perform commit.
        if status && git_has_local_changes(paths.cur_cfg)
          tell "The configuration has the following local changes:\n" +
              "#{colorize(git_local_changes(paths.cur_cfg), :white)}", :cyan
          should_commit = quiz("Do you want to commit them all")
          if should_commit
            commit_msg = quiz("Type the commit message", type: :string)
            status   = git_add
            status &&= git_commit(message: commit_msg)
          else
            status = false
          end
        end
        # (Optional) Perform pull.
        status = git_pull if status && git_should_pull(paths.cur_cfg)
        # (Optional) Perform push.
        status = git_push if status && git_should_push(paths.cur_cfg)
      end
      status
    else
      git_clone(options.cfg_url, paths.cur_cfg)
    end

    # Inform user about sync status.
    if sync_result
      tell("Synced to: `#{paths.cur_cfg}`.", :green)
    else
      error("Unable to sync.")
    end
  end

  method_option(*shared_option(:verbose))
  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name,  required: true))
  method_option(*shared_option(:inst_name, required: true))
  method_option(*shared_option(:vars_name, required: true))
  method_option(*shared_option(:meta_name))
  desc("instantiate", "Create a configuration instance in the current machine.")
  def instantiate
    # Before instantiation.
    paths = prepare_storage(options.fizzy_dir,
                            meta_name:     options.meta_name,
                            valid_inst:    false,
                            cur_cfg_name:  options.cfg_name,
                            cur_inst_name: options.inst_name)
    setup_vars(paths.cur_cfg_vars, options.vars_name)

    meta = get_meta(paths.cur_cfg_meta, paths.cur_cfg_vars, paths.cur_cfg,
                    options.verbose)

    info("meta: ", "#{colorize(meta["elems"].count, :green)}/" +
                   "#{meta["all_elems_count"]} elem(s) selected.")
    info("meta: ", "#{colorize(meta["excluded_files"].count, :red)}/" +
                   "#{meta["all_files.count"]} file(s) excluded.")
    tell

    # Create a configuration instance.
    tell("Creating a configuration instance named `#{options.inst_name}` " +
         "from: `#{paths.cur_cfg}`.", :blue)

    exclude_pattern = /\.git|README/
    meta["excluded_files"].each do |excluded_file|
      exclude_pattern = /#{exclude_pattern}|#{excluded_file}/
    end

    begin
      directory(paths.cur_cfg, paths.cur_inst, exclude_pattern: exclude_pattern)
    rescue SyntaxError
      error("Error while processing the template: `#{$fizzy_cur_template}`.")
    end

    # After instantiation.
    tell("Created the configuration instance in: `#{paths.cur_inst}`.", :green)
  end

end
