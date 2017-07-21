module Fizzy::IO

  include Fizzy::ANSIColors

  # Display a debug message (with caller info).
  #
  def debug(msg)
    caller_info = caller.
      map { |c| c[/`.*'/][1..-2].split(" ").first }.
      uniq[0..2].
      join(" → ")
    if Fizzy::CFG.debug
      tell("{m{⚫}}{b{<}}{c{#{caller_info}}}{b{>}}{w{: #{msg}}}")
    end
  end

  # Display an informative message (`msg`) to the user.
  #
  # The `prefix` argument should contain some text displayed before the
  # message, typically to show the context which the message belongs to.
  #
  def info(prefix, msg)
    tell("{b{☞ }}{c{#{prefix}}}{w{ #{msg}}}")
  end

  # Display an informative message (`msg`) to the user.
  #
  # If `ask_continue` is `true`, the user can interactively choose to stop
  # the program or exit (with exit status `-1`).
  #
  def warning(msg, ask_continue: true)
    tell("{y{☞ #{msg}}}")
    exit(-1) if ask_continue && !ask("continue")
  end

  # Display an error message (`msg`) to the user. Before returning, the
  # program will exit (with exit status `-1`).
  #
  def error(msg, exc: -1)
    tell("{r{☠ #{msg}}}")

    if exc.is_a? Integer
      exit(exc)
    elsif !exc.nil?
      raise exc.new(msg)
    end
  end

  # Tell something to the user.
  #
  def tell(*args, newline: true, **kwargs)
    unless args.empty?
      colorized_str = colorize(*args, **kwargs)
      if newline
        $stdout.puts(colorized_str)
      else
        $stdout.print(colorized_str)
      end
      $stdout.flush
    else
      puts
    end
  end

  # ────────────────────────────────────────────────────────────────────────────
  # ☞ Well-known messages

  # Get colorized success symbol.
  #
  def ✔
    "{g{✔}}"
  end

  # Get colorized error symbol.
  #
  def ✘
    "{r{✘}}"
  end

  # ────────────────────────────────────────────────────────────────────────────

end
