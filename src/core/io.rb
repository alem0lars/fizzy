module Fizzy::IO

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
  # The available quiz types are:
  # - `:bool`: Boolean quiz, the user can respond with `yes` or `no` (or
  #            alternatives, see regexes below). A boolean value is returned.
  # - `:string`: Normal quiz, the user is prompt for a question and if the
  #              answer isn't empty is returned.
  #
  def quiz(question, type: :bool)
    answer = shell.ask("#{question.strip}? ", :magenta)
    case type
    when :bool
      if answer =~ /y|ye|yes|yeah|ofc/i
        true
      elsif answer =~ /n|no|fuck|fuck\s+you|fuck\s+off/i
        false
      else
        tell("Answer misunderstood", :yellow)
        quiz(question, type: type)
      end
    when :string
      if answer.empty?
        warning("Empty answer", ask_continue: false)
        quiz(question, type: type)
      else
        answer
      end
    else
      error("Unhandled question type: `#{type}`.")
    end
  end

  def debug(msg)
    caller_info = caller.
      map { |c| c[/`.*'/][1..-2].split(" ").first }.
      uniq[0..2].
      join(" → ")

    tell(colorize("⚫ ", :magenta) +
         colorize("<", :blue) +
         colorize(caller_info, :cyan) +
         colorize(">", :blue) +
         colorize(": #{msg}", :white)) if Fizzy::CFG.debug
  end

  # Display an informative message (`msg`) to the user.
  #
  # The `prefix` argument should contain some text displayed before the
  # message, typically to show the context which the message belongs to.
  #
  def info(prefix, msg)
    tell(colorize("☞ ", :magenta) +
         colorize(prefix, :cyan) +
         colorize(" #{msg}", :white))
  end

  # Display an informative message (`msg`) to the user.
  #
  # If `ask_continue` is `true`, the user can interactively choose to stop
  # the program or exit (with exit status `-1`).
  #
  def warning(msg, ask_continue: true)
    tell(colorize("☞ ", :magenta) + colorize(msg, :yellow))
    exit(-1) if ask_continue && !quiz("continue")
  end

  # Display an error message (`msg`) to the user. Before returning, the
  # program will exit (with exit status `-1`).
  #
  def error(msg, status: -1)
    error("Invalid status code `#{status}`: it's not negative") if status >= 0
    tell(colorize("☠ ", :magenta) + colorize(msg, :red))
    exit(status)
  end

  # Tell something to the user.
  # It's a proxy method to `Thor::Shell::Color.say`.
  #
  def tell(*args)
    shell.say(*args)
  end

  # Colorize the provided string.
  # It's a proxy method to `Thor::Shell::Color.set_color`.
  #
  def colorize(*args)
    shell.set_color(*args)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # ☞ Well-known messages

  # Get colorized error symbol.
  #
  def ✘
    colorize("✘", :red)
  end

  # Get colorized success symbol.
  #
  def ✔
    colorize("✔", :green)
  end

  # ──────────────────────────────────────────────────────────────────────────

end
