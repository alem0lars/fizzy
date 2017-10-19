#
# Fizzy command to incarnate configuration.
#
class Fizzy::CLI::Incarnate < Fizzy::CLI::Command
  def initialize
    super("Incarnate configuration (a.k.a. instantiate + install).",
          spec: Fizzy::CLI.known_args(:run_mode, :fizzy_dir, :cfg_name,
                                      :inst_name, :vars_name, :meta_name))
  end

  def run
    instantiate
    install
  end

  private def instantiate
    # Before instantiation.
    paths = prepare_storage(options[:fizzy_dir],
                            meta_name:     options[:meta_name],
                            valid_cfg:     :readonly,
                            valid_inst:    false,
                            cur_cfg_name:  options[:cfg_name],
                            cur_inst_name: options[:inst_name])
    setup_vars(paths.cur_cfg_vars, options[:vars_name])

    meta = get_meta(paths.cur_cfg_meta, paths.cur_cfg_vars, paths.cur_cfg_elems,
                    options[:verbose])

    info("meta: ", "{g{#{meta[:elems].count}}}/" \
                   "#{meta[:all_elems_count]} elem(s) selected.")
    info("meta: ", "{r{#{meta[:excluded_files].count}}}/" \
                   "#{meta[:all_files_count]} file(s) excluded.")
    tell

    # Create a configuration instance.
    tell("{b{Creating a configuration instance named " \
         "`#{options[:inst_name]}`}} from: `{m{#{paths.cur_cfg}}}`.")

    exclude_pattern = Fizzy::CFG.instantiate_exclude_pattern
    meta[:excluded_files].each do |excluded_file|
      exclude_pattern = /#{exclude_pattern}|#{excluded_file}/
    end

=begin TODO ale
      begin
        directory(paths.cur_cfg, paths.cur_inst, exclude_pattern: exclude_pattern)
      rescue SyntaxError
        error("Error while processing the template: `#{$fizzy_cur_template}`.")
      end
=end

    # After instantiation.
    tell("{g{Created the configuration instance in: `#{paths.cur_inst}`.}}")
  end

  private def install
    # Prepare stuff for performing install.
    @run_mode = options[:run_mode].to_sym
    @verbose  = options[:verbose]
    paths     = prepare_storage(options[:fizzy_dir],
                                valid_cfg:     false,
                                meta_name:     options[:meta_name],
                                cur_inst_name: options[:inst_name])
    setup_vars(paths.cur_inst_vars, options[:vars_name])

    meta = get_meta(paths.cur_inst_meta, paths.cur_inst_vars,
                    paths.cur_inst_elems, options[:verbose])

    # 1: Install the instance into the system.
    tell("{b{Installing the configuration instance " \
         "`#{options[:inst_name]}` into the system.}}")
    # 1.1: Install the elements.
    meta[:elems].each do |elem|
      tell("{c{Installing element: `#{elem[:name]}`.}}")
      elements_appliers.each { |applier| applier.call(elem) }
      if elem[:notes]
        tell("{y{Notes for `#{elem[:name]}`:}}\n" +
             elem[:notes].split("\n").collect { |s| "  #{s}" }.join("\n"))
      end
    end
    # 1.2: Install the commands.
    meta[:commands].each do |command|
      tell("{c{Executing command: `#{command.type}`.}}")
      command.execute
    end

    # Inform the user about installation status.
    tell("{g{The configuration instance `#{options[:inst_name]}` has been " \
         "installed into the system.}}")
  end
end
