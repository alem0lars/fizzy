class Fizzy::InstCommand < Fizzy::BaseCommand

  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:inst_name))
  desc "cd",
       "Change directory to the instance directory " +
       "(useful for extensive filesystem manipulations)."
  def cd
    # Prepare stuff for changing directory.
    paths = prepare_storage options.fizzy_dir,
                            valid_meta:    false,
                            valid_cfg:     false,
                            valid_inst:    !options.inst_name.nil?,
                            cur_inst_name: options.inst_name

    # Changing directory.
    dir_path = paths.cur_inst || paths.inst
    say "Changing directory to: `#{dir_path}`.", :cyan
    FileUtils.cd dir_path
    system get_env! :SHELL

    # Inform user about the changing directory status.
    say "CD done in: `#{dir_path}`.", :green
  end

  method_option(*shared_option(:verbose))
  method_option(*shared_option(:run_mode))
  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:inst_name, required: true))
  method_option(*shared_option(:vars_name, required: true))
  method_option(*shared_option(:meta_name))
  desc "install",
       "Install the current configuration instance in the system."
  def install
    # Prepare stuff for performing install.
    @run_mode = options.run_mode.to_sym
    @verbose = options.verbose
    paths = prepare_storage options.fizzy_dir,
                            valid_cfg:     false,
                            meta_name:     options.meta_name,
                            cur_inst_name: options.inst_name
    setup_vars paths.cur_inst_vars, options.vars_name

    meta = get_meta paths.cur_inst_meta, paths.cur_inst_vars, paths.cur_inst,
                    options.verbose

    # Install the instance into the system.
    say "Installing the configuration instance `#{options.inst_name}` " +
        "into the system.", :blue

    meta["elems"].each do |elem|
      say "Installing element: `#{elem["name"]}`.", :cyan
      elements_appliers.each { |applier| applier.call(elem) }
      if elem["notes"]
        say "Notes for `#{elem["name"]}`:", :yellow
        say elem["notes"].split("\n").collect { |s| "  #{s}" }.join("\n")
      end
    end
    meta["commands"].each do |spec|
      say "Executing command: `#{spec["name"]}`.", :cyan
      available_commands[spec["type"]]["executor"].call spec
    end

    # Inform the user about installation status.
    say "The configuration instance `#{options.inst_name}` has been " +
        "installed into the system", :green
  end

end
