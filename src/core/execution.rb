# Utilities to start and manage programs execution.
#
module Fizzy::Execution

  include Fizzy::IO

  # Execute the provided shell command (`cmd`).
  # If `as_su` is `true` the command is executed as super user
  # (i.e. as root, using sudo).
  #
  def exec_cmd(cmd, as_su: false, chdir: nil)
    cmd = cmd.map(&:to_s).map(&:shell_escape).join(" ") if cmd.is_a?(Array)

    full_cmd = as_su ? "sudo #{cmd}" : cmd

    run_mode = defined?(@run_mode) ? @run_mode : :normal

    really_run = case run_mode
                   when :normal then true
                   when :paranoid
                     ask("Do you want to run command `#{full_cmd}`")
                   when :dry then false
                   else true
                 end

    if really_run || run_mode == :dry
      tell(as_su ? "{m{[sudo]}} #{cmd}" : cmd)
    end

    status = nil
    if really_run
      if chdir
        FileUtils.cd(chdir) do
          status = system(full_cmd)
        end
      else
        status = system(full_cmd)
      end
      warning("Command `#{full_cmd}` failed.") unless status
    end
    status
  end

end
