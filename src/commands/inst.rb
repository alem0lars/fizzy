class Fizzy::InstCommand < Fizzy::BaseCommand

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:inst_name))
  desc("cd", "Change directory to the instance directory " +
             "(useful for extensive filesystem manipulations).")
  def cd
    # Prepare stuff for changing directory.
    paths = prepare_storage(options.fizzy_dir,
                            valid_meta:    false,
                            valid_cfg:     false,
                            valid_inst:    !options.inst_name.nil?,
                            cur_inst_name: options.inst_name)

    # Changing directory.
    dir_path = paths.cur_inst || paths.inst
    tell("Changing directory to: `#{dir_path}`.", :cyan)
    FileUtils.cd(dir_path)
    system get_env!(:SHELL)

    # Inform user about the changing directory status.
    tell("CD done in: `#{dir_path}`.", :green)
  end

  method_option(*shared_option(:verbose))
  method_option(*shared_option(:run_mode))
  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:inst_name, required: true))
  method_option(*shared_option(:vars_name, required: true))
  method_option(*shared_option(:meta_name))
  desc("install", "Install the current configuration instance in the system.")
  def install
    # Prepare stuff for performing install.
    @run_mode = options.run_mode.to_sym
    @verbose  = options.verbose
    paths = prepare_storage(options.fizzy_dir,
                            valid_cfg:     false,
                            meta_name:     options.meta_name,
                            cur_inst_name: options.inst_name)
    setup_vars(paths.cur_inst_vars, options.vars_name)

    meta = get_meta(paths.cur_inst_meta, paths.cur_inst_vars, paths.cur_inst_elems,
                    options.verbose)

    # 1: Install the instance into the system.
    tell("Installing the configuration instance `#{options.inst_name}` " +
         "into the system.", :blue)
    # 1.1: Install the elements.
    meta[:elems].each do |elem|
      tell("Installing element: `#{elem[:name]}`.", :cyan)
      elements_appliers.each { |applier| applier.call(elem) }
      if elem[:notes]
        tell("Notes for `#{elem[:name]}`:", :yellow)
        tell(elem[:notes].split("\n").collect { |s| "  #{s}" }.join("\n"))
      end
    end
    # 1.2: Install the commands.
    meta[:commands].each do |spec|
      tell("Executing command: `#{spec[:name]}`.", :cyan)
      available_commands[spec[:type]][:executor].call(spec)
    end

    # Inform the user about installation status.
    tell("The configuration instance `#{options.inst_name}` has been " +
         "installed into the system", :green)
  end

end
