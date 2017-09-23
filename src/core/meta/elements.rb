#
# Manage elements declared in the meta file.
#
module Fizzy::Meta::Elements

  include Fizzy::IO
  include Fizzy::Execution

  #
  # Get a list of functions capable to apply modifications on the system
  # based on the current elements configuration instance.
  #
  # In particular, an applier work for each element installed.
  #
  def elements_appliers
    [lambda { |elem| # Create parent directories.
      elem[:fs_maps].each do |m|
        parent_dir = m[:dst_path].dirname
        unless parent_dir.directory?
          exec_cmd("mkdir -p #{parent_dir.shell_escape}",
                   as_su: !existing_dir(parent_dir))
        end
      end
    },
     lambda { |elem| # Create a symlink for each elements' `src_path`.
      elem[:fs_maps].each do |m|
        tell("  {m{#{m[:src_path]}}} ← {m{#{m[:dst_path]}}}") if @verbose
        cmd         = "ln -s"
        should_link = if m[:dst_path].file?
                        if m[:dst_path].realpath != m[:src_path]
                          cmd << " -f"
                          ask("The destination file `#{m[:dst_path]}` " \
                              "already exists. Overwrite")
                        else
                          false
                        end
                      elsif m[:dst_path].directory?
                        if ask("The destination file `#{m[:dst_path]}` " \
                               "is a directory. Delete it")
                          exec_cmd("rm -Rf #{m[:dst_path]}",
                                   as_su: !existing_dir(m[:dst_path].dirname))
                        end
                      else
                        # Link does not exist yet.
                        true
                      end

        next unless should_link
        cmd << " #{m[:src_path].shell_escape}"
        cmd << " #{m[:dst_path].shell_escape}"
        exec_cmd(cmd, as_su: !existing_dir(m[:dst_path].dirname))
      end
    },
     lambda { |elem| # Change perms of the instantiated files (if specified).
      if elem.key?(:perms)
        elem[:fs_maps].each do |m|
          if @verbose
            tell("Changing permissions of `{m{#{m[:src_path]}}}` to " \
                 "`{m{#{elem[:perms]}}}`.")
          end
          perms    = elem[:perms].shell_escape
          src_path = m[:src_path].shell_escape
          exec_cmd("chmod #{perms} #{src_path}",
                   as_su: !File.owned?(m[:src_path]))
        end
      end
    }]
  end
end
