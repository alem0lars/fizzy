# Manage elements declared in the meta file.
#
module Fizzy::MetaElements

  include Fizzy::IO
  include Fizzy::Execution

  # Return a list of functions capable to apply modifications on the system
  # based on the current elements configuration instance.
  #
  # In particular, an applier work for each element installed.
  #
  def elements_appliers
    [ lambda { |elem| # Create parent directories.
        elem["fs_maps"].each do |m|
          parent_dir = File.dirname(m["dst_path"])
          if elem.has_key?("perms")
            l_ex_dir_path = f_noex_dir_path = parent_dir
            while !File.directory?(l_ex_dir_path)
              f_noex_dir_path = l_ex_dir_path
              l_ex_dir_path   = File.dirname(l_ex_dir_path)
            end
          else
            l_ex_dir_path = f_noex_dir_path = nil
          end
          # From here, we have the following variable set:
          # - `l_ex_dir_path`: Longest path prefix which points to an existing
          #                    directory.
          # - `f_noex_dir_path`: Path of the first directory after the prefix
          #                      which points to an existing dir.
          if !File.directory?(parent_dir)
            exec_cmd("mkdir -p #{Shellwords.escape(parent_dir)}",
                     as_su: !existing_dir(parent_dir))
          end
        end
      },
      lambda { |elem| # Create a symlink for each elements' `src_path`.
        elem["fs_maps"].each do |m|
          tell("  #{m["src_path"]} ← #{m["dst_path"]}") if @verbose
          cmd = "ln -s"
          should_link = if File.file?(m["dst_path"])
            dst_real_path = Pathname.new(m["dst_path"]).realpath.to_s
            if dst_real_path != m["src_path"]
              cmd << " -f"
              quiz("The destination file `#{m["dst_path"]}` already " +
                   "exists. Overwrite")
            else
              false
            end
          elsif File.directory?(m["dst_path"])
            if quiz("The destination file `#{m["dst_path"]}` is a " +
                    "directory. Delete it")
              exec_cmd("rm -Rf #{m["dst_path"]}",
                       as_su: !existing_dir(File.dirname(m["dst_path"])))
            end
          else
            # Link does not exist yet.
            true
          end

          if should_link
            cmd << " #{Shellwords.escape m["src_path"]}"
            cmd << " #{Shellwords.escape m["dst_path"]}"
            exec_cmd(cmd, as_su: !existing_dir(File.dirname(m["dst_path"])))
          end
        end
      },
      lambda { |elem| # Change perms of the instantiated files (if specified).
        if elem.has_key?("perms")
          elem["fs_maps"].each do |m|
            tell("Changing permissions of #{m["src_path"]} to " +
                 elem["perms"]) if @verbose
            exec_cmd("chmod -R #{Shellwords.escape(elem["perms"])} " +
                     Shellwords.escape(m["src_path"]),
                     as_su: !File.owned?(m["src_path"]))
          end
        end
      }
    ]
  end

end
