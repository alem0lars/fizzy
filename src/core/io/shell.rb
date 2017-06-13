module Fizzy::IO

  include Fizzy::ANSIColors

  # Get the shell object.
  # It will be lazily instantiated.
  def shell
    @shell ||= Thor::Shell::Color.new
  end

  # Ask a question to the user.
  #
  # The message is made by the `question` string, with some additions (like
  # `?` sign).
  #
  # The available ask types are:
  # - `:bool`: Boolean ask, the user can respond with `yes` or `no` (or
  #            alternatives, see regexes below). A boolean value is returned.
  # - `:string`: Normal ask, the user is prompt for a question and if the
  #              answer isn't empty is returned.
  #
  def ask(question, type: :bool)
    answer = shell.ask("#{question.strip}? ", :magenta)
    case type
      when :bool
        if answer =~ /y|ye|yes|yeah|ofc/i
          true
        elsif answer =~ /n|no|fuck|fuck\s+you|fuck\s+off/i
          false
        else
          tell("{y{Answer misunderstood}}")
          ask(question, type: type)
        end
      when :string
        if answer.empty?
          warning("Empty answer", ask_continue: false)
          ask(question, type: type)
        else
          answer
        end
      else error("Unhandled question type: `#{type}`.")
    end
  end

  def debug(msg)
    caller_info = caller.
      map { |c| c[/`.*'/][1..-2].split(" ").first }.
      uniq[0..2].
      join(" → ")
    tell("{m{⚫}}{b{<}}{c{#{caller_info}}}{b{>}}{w{: #{msg}}}") if Fizzy::CFG.debug
  end

  # Display an informative message (`msg`) to the user.
  #
  # The `prefix` argument should contain some text displayed before the
  # message, typically to show the context which the message belongs to.
  #
  def info(prefix, msg)
    tell("{m{☞}} {c{#{prefix}}} {w{#{msg}}}")
  end

  # Display an informative message (`msg`) to the user.
  #
  # If `ask_continue` is `true`, the user can interactively choose to stop
  # the program or exit (with exit status `-1`).
  #
  def warning(msg, ask_continue: true)
    tell("{m{☞}} {y{#{msg}}}")
    exit(-1) if ask_continue && !ask("continue")
  end

  # Display an error message (`msg`) to the user. Before returning, the
  # program will exit (with exit status `-1`).
  #
  def error(msg, exc: nil)
    must "message", msg, be: String

    tell("{m{☠}} {r{#{msg}}}")

    if exc
      raise exc.new(msg)
    else
      exit(-1)
    end
  end

  # Tell something to the user.
  #
  def tell(*args, **kwargs)
    puts colorize(*args, **kwargs)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # ☞ Well-known messages

  # Get colorized success symbol.
  #
  def ✔(str)
    "{g{✔}}"
  end

  # Get colorized error symbol.
  #
  def ✘(str)
    "{r{✘}}"
  end

  # ──────────────────────────────────────────────────────────────────────────

end
