class Fizzy::CfgCommand < Fizzy::BaseCommand

  def self.source_root
    "/"
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
    status = if ask("Remove the fizzy root directory (`#{paths.root}`)")
      paths.root.rmtree
    else
      nil # Cleanup skipped.
    end

    # Inform user about the cleanup status.
    case status
      when true  then tell("{g{Successfully cleaned: `#{paths.root}`.}}")
      when false then error("Failed to cleanup: `#{paths.root}`.", :red)
      when nil   then warning("Cleanup skipped.", ask_continue: false)
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
    tell("{c{Changing directory to: `#{dir_path}`.}}")
    FileUtils.cd(dir_path)
    system(get_env!(:SHELL))

    # Inform user about the changing directory status.
    tell("{g{CD done in: `#{dir_path}`.}}")
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
    cfg_files = if find_path.exist?
      Array[find_path]
    else
      Pathname.glob("#{find_path}*", File::FNM_DOTMATCH).to_a
              .select(&:file?)
              .reject{|path| path.to_s =~ /\.git/}
    end

    cfg_files_arg = cfg_files.collect{|path| path.shell_escape}
                             .join(" ")
                             .strip

    # Perform edit.
    status = if cfg_files_arg.empty?
      warning("No files matching `#{options.cfg_name}` have been found.",
              ask_continue: false)
      nil
    else
      tell("{c{Editing configuration file(s): `#{cfg_files_arg}`.}}")
      system("#{Fizzy::CFG.editor} #{cfg_files_arg}")
    end

    # Inform user about the editing status.
    case status
      when true  then tell("{g{Successfully edited: `#{cfg_files_arg}`.}}")
      when false then error("Failed to edit: `#{cfg_files_arg}`.", :red)
      when nil   then warning("Editing skipped.", ask_continue: false)
    end
  end

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name, required: true))
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
    sync_result = Fizzy::Sync.perform(paths.cur_cfg, options.cfg_url)

    # Inform user about sync status.
    if sync_result
      tell("{g{Synced to: `#{paths.cur_cfg}`.}}")
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
                            valid_cfg:     :readonly,
                            valid_inst:    false,
                            cur_cfg_name:  options.cfg_name,
                            cur_inst_name: options.inst_name)
    setup_vars(paths.cur_cfg_vars, options.vars_name)

    meta = get_meta(paths.cur_cfg_meta, paths.cur_cfg_vars, paths.cur_cfg_elems,
                    options.verbose)

    info("meta: ", "{g{#{meta[:elems].count}}}/" +
                   "#{meta[:all_elems_count]} elem(s) selected.")
    info("meta: ", "{r{#{meta[:excluded_files].count}}}/" +
                   "#{meta[:all_files_count]} file(s) excluded.")
    tell

    # Create a configuration instance.
    tell("{b{Creating a configuration instance named `#{options.inst_name}`}} from: `{m{#{paths.cur_cfg}}}`.")

    exclude_pattern = Fizzy::CFG.instantiate_exclude_pattern
    meta[:excluded_files].each do |excluded_file|
      exclude_pattern = /#{exclude_pattern}|#{excluded_file}/
    end

    begin
      directory(paths.cur_cfg, paths.cur_inst, exclude_pattern: exclude_pattern)
    rescue SyntaxError
      error("Error while processing the template: `#{$fizzy_cur_template}`.")
    end

    # After instantiation.
    tell("{g{Created the configuration instance in: `#{paths.cur_inst}`.}}")
  end

end
