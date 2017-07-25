#
# Definition of specs for known arguments and relative utilities.
#
module Fizzy::CLI
  #
  # Specs for known arguments.
  #
  KNOWN_ARGS = {
    run_mode: {
      desc: "How fizzy will perform its operations, e.g. simulating them " \
        "or not",
      abbrev: "R",
      default: "normal",
      type: %i[normal dry]
    },
    fizzy_dir: {
      desc: "Specify fizzy directory",
      abbrev: "D",
      default: Fizzy::CFG.default_fizzy_dir,
      type: Pathname
    },
    cfg_url: {
      desc: "The URL to the repository holding configuration.",
      abbrev: "U",
      required: true
    },
    cfg_name: {
      desc: "The name of the configuration that should be used.",
      abbrev: "C",
      required: true
    },
    inst_name: {
      desc: "The name for the configuration instance to be used.",
      aliases: "I",
      required: true
    },
    vars_name: {
      desc: "The name for the variables file to be used.",
      aliases: "V",
      required: true
    },
    meta_name: {
      desc: "The name of the meta file.",
      aliases: "M",
      default: Fizzy::CFG.default_meta_name
    }
  }.freeze

  #
  # Get specs for known fizzy command-line arguments.
  #
  def self.known_args(*names, **kwnames)
    KNOWN_ARGS.select do |name, info|
      next true if names.include?(name)
      kwnames.each do |kwname, kwinfo|
        info.deep_merge!(kwinfo) if name == kwname
        next true if name == kwname
      end
      next false
    end
  end
end
