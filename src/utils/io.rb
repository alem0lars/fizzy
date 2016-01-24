# I/O & Logging

module Fizzy::Utils

  #
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
    answer = ask "#{question.strip}? ", :magenta
    case type
    when :bool
      if answer =~ /y|ye|yes|yeah|ofc/i
        true
      elsif answer =~ /n|no|fuck|fuck\s+you|fuck\s+off/i
        false
      else
        say 'Answer misunderstood', :yellow
        quiz(question, :type => type)
      end
    when :string
      if answer.empty?
        warning 'Empty answer', :ask_continue => false
        quiz(question, :type => type)
      else
        answer
      end
    else
      error "Unhandled question type: `#{type}`."
    end
  end

  #
  # Display an informative message (`msg`) to the user.
  #
  # The `prefix` argument should contain some text displayed before the
  # message, typically to show the context which the message belongs to.
  #
  def info(prefix, msg)
    say("☞ #{set_color(prefix, :cyan)}#{set_color(msg, :white)}")
  end

  #
  # Display an informative message (`msg`) to the user.
  #
  # If `ask_continue` is `true`, the user can interactively choose to stop
  # the program or exit (with exit status `-1`).
  #
  def warning(msg, ask_continue: true)
    say "⚠ #{msg}", :yellow
    exit(-1) if ask_continue && !quiz('continue')
  end

  #
  # Display an error message (`msg`) to the user. Before returning, the
  # program will exit (with exit status `-1`).
  #
  def error(msg)
    say "☠ #{msg}", :red
    exit(-1)
  end

end
