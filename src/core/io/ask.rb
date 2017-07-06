module Fizzy::IO

  # Ask a question to the user.
  #
  # The message is made by the `question` string, with some additions (like
  # `?` sign if not already present).
  #
  # The available ask types are:
  # - `:bool`: Boolean ask, the user can respond with `yes` or `no` (or
  #            alternatives, see regexes below). A boolean value is returned.
  # - `:string`: Normal ask, the user is prompt for a question and if the
  #              answer isn't empty is returned.
  #
  def ask(question, type: :bool)
    question = question.gsub(/[?]*/, "")
    question.strip!
    question << "? "

    tell("{Ml{ ? }}#{question}")
    answer = $stdin.gets.chomp

    case type
    when :bool
      if answer =~ /(y|ye|yes|yeah|ofc)$/i
        true
      elsif answer =~ /(n|no|fuck|fuck\s+you|fuck\s+off)$/i
        false
      else
          tell("{y{Answer misunderstood}}.")
          ask(question, type: type)
      end
    when :string
      if answer.empty?
          warning("Empty answer", ask_continue: false)
          ask(question, type: type)
      else
        answer
      end
    else error("Unhandled question type: `{m{#{type}}}`.")
    end
  end

end
