class Fizzy::MainCommand < Fizzy::BaseCommand

  desc("cfg SUBCOMMAND ...ARGS", "Manage the fizzy configuration " +
                                 "(without modifying the host system).")
  subcommand("cfg", Fizzy::CfgCommand)

  desc("inst SUBCOMMAND ...ARGS", "Manage a configuration instance")
  subcommand("inst", Fizzy::InstCommand)

  desc("usage", "Show how to use fizzy.")
  def usage
    url = URI.join(Fizzy::CFG.static_files_base_url, "README.md")
    res = Net::HTTP.get_response(url)
    if res.is_a?(Net::HTTPSuccess)
      tell("\n#{res.body}\n")
    else
      error("Network error: cannot retrieve `#{url}`.")
    end
  end

  desc("version", "Show fizzy version.")
  def version
    info "fizzy version", Fizzy::CFG.version
    info "ruby version", "ruby #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}"
  end

  method_option(*shared_option(:verbose))
  method_option(*shared_option(:run_mode))
  method_option(*shared_option(:fizzy_dir))
  method_option(*shared_option(:cfg_name,  required: true))
  method_option(*shared_option(:inst_name, required: true))
  method_option(*shared_option(:vars_name, required: true))
  method_option(*shared_option(:meta_name))
  desc("quick-install", "Quickly install a configuration.")
  def quick_install
    invoke(Fizzy::CfgCommand, "instantiate", [],
           cfg_name:  options.cfg_name,
           vars_name: options.vars_name,
           inst_name: options.inst_name,
           fizzy_dir: options.fizzy_dir,
           meta_name: options.meta_name,
           verbose:   options.verbose)
    invoke(Fizzy::InstCommand, "install", [],
           vars_name: options.vars_name,
           inst_name: options.inst_name,
           fizzy_dir: options.fizzy_dir,
           meta_name: options.meta_name,
           run_mode:  options.run_mode,
           verbose:   options.verbose)
  end
  map :qi => :quick_install

end
