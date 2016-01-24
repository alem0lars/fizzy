# Base class for all fizzy commands.
#
class Fizzy::BaseCommand < Thor

  include Thor::Actions

  include Fizzy::Environment
  include Fizzy::Execution
  include Fizzy::Filesystem
  include Fizzy::Git
  include Fizzy::IO
  include Fizzy::MetaInfo
  include Fizzy::MetaElements
  include Fizzy::MetaCommands
  include Fizzy::Vars

  # Common options, shared among many commands.
  #
  SHARED_OPTIONS = {
    verbose: {
      default: false,
      type:    :boolean,
      aliases: :verb,
      desc:    "Whether the output should be verbose."
    },
    run_mode: {
      default: "normal",
      aliases: [:rm, :r],
      enum:    %w(normal paranoid dry),
      desc:    "Ask confirmation for each filesystem operation."
    },
    fizzy_dir: {
      default: Fizzy::CFG.default_fizzy_dir,
      aliases: :f,
      desc:    "The root path for the directory internally used by fizzy."
    },
    cfg_url: {
      default: nil,
      aliases: [:cu],
      desc: "The URL to the repository holding config."
    },
    cfg_name: {
      default: nil,
      aliases: [:cfg, :c],
      desc:    "The name of the configuration that should be used."
    },
    inst_name: {
      default: nil,
      aliases: [:inst, :i],
      desc:    "The name for the configuration instance to be used."
    },
    vars_name: {
      default: nil,
      aliases: [:vars, :v],
      desc:    "The name for the variables file to be used."
    },
    meta_name: {
      default: Fizzy::CFG.default_meta_name,
      aliases: [:meta, :m],
      desc:    "The name of the meta file."
    }
  }

  # Get a shared option.
  #
  def self.shared_option(name, required: false)
    args = SHARED_OPTIONS[$1].dup
    error "Invalid option `#{name}`: it doesn't exist." if args.nil?

    if required
      args.delete :default
      args[:required] = true
    else
      error "Invalid shared option `#{name}`: it doesn't have a default value."
    end

    [$1, args]
  end

end
