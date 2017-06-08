# Base class for all fizzy commands.
#
class Fizzy::BaseCommand < Thor

  include Thor::Actions

  include Fizzy::Environment
  include Fizzy::Execution
  include Fizzy::Filesystem
  include Fizzy::IO
  include Fizzy::Vars
  include Fizzy::Locals
  include Fizzy::MetaInfo
  include Fizzy::MetaElements
  include Fizzy::MetaCommands

  # Common options, shared by many commands.
  #
  SHARED_OPTIONS = {
    verbose: {
      default: false,
      type:    :boolean,
      aliases: :v,
      desc:    "Whether the output should be verbose."
    },
    run_mode: {
      default: "normal",
      aliases: :R,
      enum:    %w(normal paranoid dry),
      desc:    "Ask confirmation for each filesystem operation."
    },
    fizzy_dir: {
      default: Fizzy::CFG.default_fizzy_dir.to_s,
      aliases: :F,
      desc:    "The root path for the directory internally used by fizzy."
    },
    cfg_url: {
      default: nil,
      aliases: :U,
      desc: "The URL to the repository holding config."
    },
    cfg_name: {
      default: nil,
      aliases: :C,
      desc:    "The name of the configuration that should be used."
    },
    inst_name: {
      default: nil,
      aliases: :I,
      desc:    "The name for the configuration instance to be used."
    },
    vars_name: {
      default: nil,
      aliases: :V,
      desc:    "The name for the variables file to be used."
    },
    meta_name: {
      default: Fizzy::CFG.default_meta_name,
      aliases: :M,
      desc:    "The name of the meta file."
    }
  }

  class << self

    include Fizzy::IO

    # @return a shared option.
    #
    def shared_option(name, required: false)
      args = SHARED_OPTIONS[name].dup
      error("Invalid option `#{name}`: it doesn't exist.") if args.nil?

      if required
        args.delete(:default)
        args[:required] = true
      elsif !args.has_key?(:default)
        error("Invalid shared option `#{name}`: doesn't have a default value.")
      end

      [name, args]
    end

  end

end
