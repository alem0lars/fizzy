class Fizzy::CfgCommand < Fizzy::BaseCommand

  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by fizzy.'
  desc 'cleanup', 'Cleanup the fizzy storage (i.e. configuration, instances).'
  def cleanup
    # Prepare paths for cleanup.
    paths = prepare_storage(options.fizzy_dir, :valid_meta => false,
                            :valid_cfg => false, :valid_inst => false)

    # Perform cleanup.
    status = if quiz "Do you want to remove the fizzy root directory `#{paths.root}`"
      exec_cmd("rm -Rf \"#{paths.root}\"")
    else
      nil
    end

    # Inform user about the cleanup status.
    if status
      say "Successfully cleaned: `#{paths.root}`.", :green
    elsif status.nil?
      warning 'Cleanup skipped.', :ask_continue => false
    else
      error "Failed to cleanup: `#{paths.root}`.", :red
    end
  end

  option :cfg_name, :default => nil, :aliases => [:cfg, :c],
         :desc => 'The name of the configuration that should be used.'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by Fizzy.'
  desc 'cd', 'Change directory to the configuration directory (useful for extensive filesystem manipulations).'
  def cd
    # Prepare stuff for changing directory.
    paths = prepare_storage(options.fizzy_dir,
                            :valid_meta   => false,
                            :valid_inst   => false,
                            :valid_cfg    => !options.cfg_name.nil?,
                            :cur_cfg_name => options.cfg_name)

    # Changing directory.
    dir_path = paths.cur_cfg || paths.cfg
    say "Changing directory to: `#{dir_path}`.", :cyan
    FileUtils.cd(dir_path)
    if ENV.has_key?('SHELL')
      system(ENV['SHELL'])
    else
      error 'Cannot find a valid shell. The environment variable `SHELL` is unset.'
    end

    # Inform user about the changing directory status.
    say "CD done in: `#{dir_path}`.", :green
  end

  option :cfg_name, :default => nil, :aliases => [:cfg, :c],
         :desc => 'The name of the configuration that should be used.'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by Fizzy.'
  desc 'edit PATTERN', 'Find the files relative to PATTERN and edit them.'
  def edit(pattern)
    # Prepare stuff for editing.
    paths = prepare_storage(options.fizzy_dir,
                            :valid_meta   => false,
                            :valid_inst   => false,
                            :cur_cfg_name => options.cfg_name)
    find_path = File.join(paths.cur_cfg || paths.cfg, pattern)
    cfg_files_arg = (File.exist?(find_path) ?
        "\"#{find_path}\"" :
        Dir.glob("#{find_path}*", File::FNM_DOTMATCH).to_a
            .delete_if { |path| path =~ /\.git/ }
            .collect { |path| "\"#{path}\"" }
            .join(' ')
    ).strip
    editor = Fizzy::CFG.editor

    # Perform edit.
    if cfg_files_arg.empty?
      warning "No files matching `#{cfg_name}` have been found.",
              :ask_continue => false
      status = nil
    else
      say "Editing configuration file(s): `#{cfg_files_arg}`.", :cyan
      status = system("#{editor} #{cfg_files_arg}")
    end

    # Inform user about the editing status.
    if status
      say "Successfully edited: `#{cfg_files_arg}`.", :green
    elsif status.nil?
      warning 'Editing skipped.', :ask_continue => false
    else
      error "Failed to edit: `#{cfg_files_arg}`.", :red
    end
  end

  option :cfg_name, :required => true, :aliases => [:cfg, :c],
         :desc => 'The name of the configuration that should be used.'
  option :url, :default => nil, :aliases => :u,
         :desc => 'The url to the repository holding config (currently supported: `git`).'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by Fizzy.'
  desc 'sync', 'Synchronize the remote repository with the local one.'
  def sync
    # Prepare stuff for syncing.
    paths = prepare_storage(options.fizzy_dir,
                            :valid_meta   => false,
                            :valid_cfg    => false,
                            :valid_inst   => false,
                            :cur_cfg_name => options.cfg_name)

    # Perform sync.
    sync_result = if File.directory?(paths.cur_cfg)
      say 'Syncing from origin', :blue
      status = nil
      FileUtils.cd(paths.cur_cfg) do
        # Perform fetch, because we need to know if there are remote changes,
        # so we need to know the updated remote commit hash.
        say 'Fetching informations from origin', :cyan
        status = system('git fetch origin')
        # (Optional) Perform commit.
        if status && git_has_local_changes(paths.cur_cfg)
          say "The configuration has the following local changes:\n" +
              "#{set_color(git_local_changes(paths.cur_cfg), :white)}", :cyan
          should_commit = quiz 'Do you want to commit them all'
          if should_commit
            commit_msg = quiz 'Type the commit message', :type => :string
            say 'Performing commit.', :cyan
            status   = system('git add -A')
            status &&= system("git commit -am \"#{commit_msg}\"")
          else
            status = false
          end
        end
        # (Optional) Perform pull.
        if status && git_should_pull(paths.cur_cfg)
          status = git_pull
        end
        # (Optional) Perform push.
        if status && git_should_push(paths.cur_cfg)
          say 'Performing push.', :cyan
          status = system('git push origin master')
        end
      end
      status
    else
      git_clone(options.url, paths.cur_cfg)
    end

    # Inform user about sync status.
    if sync_result
      say "Synced to: `#{paths.cur_cfg}`.", :green
    else
      error 'Unable to sync.'
    end
  end

  option :cfg_name, :required => true, :aliases => [:cfg, :c],
         :desc => 'The name of the configuration that should be used.'
  option :vars_name, :required => true, :aliases => [:vars, :v],
         :desc => 'The name for the variables file to be used.'
  option :inst_name, :required => true, :aliases => [:inst, :i],
         :desc => 'The name for the new configuration instance.'
  option :meta_name, :default => Fizzy::CFG.default_meta_name, :aliases => [:meta, :m],
         :desc => 'Name of the meta file (e.g. meta-user-alem0lars.yml)'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by Fizzy.'
  option :verbose, :type => :boolean, :default => false, :aliases => :verb,
         :desc => 'Whether the output should be verbose.'
  desc 'instantiate', 'Create a configuration instance in the current machine.'
  def instantiate
    # Before instantiation.
    paths = prepare_storage(options.fizzy_dir,
                            :meta_name     => options.meta_name,
                            :valid_inst    => false,
                            :cur_cfg_name  => options.cfg_name,
                            :cur_inst_name => options.inst_name)
    setup_vars(paths.cur_cfg_vars, options.vars_name)

    meta = get_meta(paths.cur_cfg_meta, paths.cur_cfg_vars, paths.cur_cfg,
                    options.verbose)

    info 'meta: ', "#{set_color(meta['elems'].count, :green)}/" +
                   "#{meta['all_elems_count']} elem(s) selected."
    info 'meta: ', "#{set_color(meta['excluded_files'].count, :red)}/" +
                   "#{meta['all_files.count']} file(s) excluded."
    say

    # Create a configuration instance.
    say "Creating a configuration instance named `#{options.inst_name}` " +
        "from: `#{paths.cur_cfg}`.", :blue

    exclude_pattern = /\.git|README/
    meta['excluded_files'].each do |excluded_file|
      exclude_pattern = /#{exclude_pattern}|#{excluded_file}/
    end

    begin
      directory(paths.cur_cfg, paths.cur_inst,
                :exclude_pattern => exclude_pattern)
    rescue SyntaxError
      error "Error while processing the template: `#{$fizzy_cur_template}`."
    end

    # After instantiation.
    say "Created the configuration instance in: `#{paths.cur_inst}`.", :green
  end

  def self.source_root
    "/"
  end

end
