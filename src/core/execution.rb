# Utilities to start and manage programs execution.
#
module Fizzy::Execution

  include Fizzy::IO

  # Execute the provided shell command (`cmd`).
  # If `as_su` is `true` the command is executed as super user
  # (i.e. as root, using sudo).
  #
  def exec_cmd(cmd, as_su: false)
    full_cmd = as_su ? "sudo #{cmd}" : cmd

    really_run = case @run_mode
                   when :normal then true
                   when :paranoid
                     quiz("Do you want to run command `#{full_cmd}`")
                   when :dry then false
                   else true
                 end

    if really_run || @run_mode == :dry
      tell(as_su ? "[sudo] #{cmd}" : cmd, :magenta)
    end

    if really_run
      system(full_cmd) || warning("Command `#{full_cmd}` failed.")
    end
  end

end
