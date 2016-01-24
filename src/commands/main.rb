class Fizzy::MainCommand < Thor

  include Fizzy::Utils

  desc 'cfg SUBCOMMAND ...ARGS',
       'Manage the Fizzy configuration (without modifying the host system).'
  subcommand 'cfg', Fizzy::CfgCommand

  desc 'inst SUBCOMMAND ...ARGS', 'Manage a configuration instance'
  subcommand 'inst', Fizzy::InstCommand

  desc 'usage', 'Show how to use Fizzy.'
  def usage
    url = 'https://raw.githubusercontent.com/alem0lars/fizzy/master/README.md'
    res = Net::HTTP.get_response(URI(url))
    if res.is_a?(Net::HTTPSuccess)
      say "\n#{res.body}\n"
    else
      error "Network error: cannot retrieve `#{url}`."
    end
  end

  option :cfg_name, :required => true, :aliases => [:cfg, :c],
         :desc => 'The name of the configuration that should be used.'
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
  desc 'quick-install', 'Quickly install a configuration.'
  def quick_install
    invoke Cfg, 'instantiate', [],
           :cfg_name => options.cfg_name, :vars_name => options.vars_name,
           :inst_name => options.inst_name, :fizzy_dir => options.fizzy_dir,
           :meta_name => options.meta_name, :verbose => options.verbose
    invoke Inst, 'install', [],
           :vars_name => options.vars_name, :inst_name => options.inst_name,
           :fizzy_dir => options.fizzy_dir, :meta_name => options.meta_name,
           :run_mode => options.run_mode, :verbose => options.verbose
  end
  map :qi => :quick_install
end
