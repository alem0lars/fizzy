class Fizzy::InstCommand < Fizzy::BaseCommand

  option :inst_name, :default => nil, :aliases => [:inst, :i],
         :desc => 'The name for the configuration instance.'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by fizzy.'
  desc 'cd', 'Change directory to the instance directory (useful for extensive filesystem manipulations).'
  def cd
    # Prepare stuff for changing directory.
    paths = prepare_storage(options.fizzy_dir,
                            :valid_meta    => false,
                            :valid_cfg     => false,
                            :valid_inst    => !options.inst_name.nil?,
                            :cur_inst_name => options.inst_name)

    # Changing directory.
    dir_path = paths.cur_inst || paths.inst
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

  option :vars_name, :required => true, :aliases => [:vars, :v],
         :desc => 'The name for the variables file to be used.'
  option :inst_name, :required => true, :aliases => [:inst, :i],
         :desc => 'The name for the new configuration instance.'
  option :meta_name, :default => Fizzy::CFG.default_meta_name, :aliases => [:meta, :m],
         :desc => 'Name of the meta file (e.g. meta-user.yml).'
  option :fizzy_dir, :default => Fizzy::CFG.default_fizzy_dir, :aliases => :f,
         :desc => 'The root path for the directory internally used by fizzy.'
  option :run_mode, :default => 'normal', :aliases => [:rm, :r],
         :enum => ['normal', 'paranoid', 'dry'],
         :desc => 'Ask confirmation for each filesystem operation.'
  option :verbose, :type => :boolean, :default => false, :aliases => :verb,
         :desc => 'If the output should be verbose.'
  desc 'install', 'Install the current configuration instance in the system.'
  def install
    # Prepare stuff for performing install.
    @run_mode = options.run_mode.to_sym
    @verbose = options.verbose
    paths = prepare_storage(options.fizzy_dir,
                            :valid_cfg     => false,
                            :meta_name     => options.meta_name,
                            :cur_inst_name => options.inst_name)
    setup_vars(paths.cur_inst_vars, options.vars_name)

    meta = get_meta(paths.cur_inst_meta, paths.cur_inst_vars, paths.cur_inst,
                    options.verbose)

    # Install the instance into the system.
    say "Installing the configuration instance `#{options.inst_name}` " +
        "into the system.", :blue

    meta['elems'].each do |elem|
      say "Installing element: `#{elem['name']}`.", :cyan
      elements_appliers.each { |applier| applier.call(elem) }
      if elem['notes']
        say "Notes for `#{elem['name']}`:", :yellow
        say elem['notes'].split("\n").collect { |s|
          "  #{s}"
        }.join("\n")
      end
    end
    meta['commands'].each do |spec|
      say "Executing command: `#{spec['name']}`.", :cyan
      available_commands[spec['type']]['executor'].call(spec)
    end

    # Inform the user about installation status.
    say "The configuration instance `#{options.inst_name}` has been " +
        'installed into the system', :green
  end

end
