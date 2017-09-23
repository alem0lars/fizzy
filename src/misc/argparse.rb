module Fizzy::ArgParse
  # ───────────────────────────────────────────────────────────────────── API ──

  def self.define_command(*args, **kwargs)
    Proxy.new.define_command(*args, **kwargs)
  end

  class Proxy
    attr_reader :command, :handlers

    def initialize
      @command  = Command.new
      @handlers = []
    end

    def define_command(*args, **kwargs)
      command.add_subcommand(*args, **kwargs)
      self
    end

    def run(args)
      command.run if command.parse(args)
    end
  end

  # ────────────────────────────────────────────────────────────────────────────
end
