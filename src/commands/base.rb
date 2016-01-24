class Fizzy::BaseCommand < Thor
  include Thor::Actions
  include Fizzy::Utils

  protected

  #
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
            exec_cmd("mkdir -p \"#{parent_dir}\"",
                     as_su: !existing_dir(parent_dir))
          end
        end
      },
      lambda { |elem| # Create a symlink for each elements' `src_path`.
        elem["fs_maps"].each do |m|
          say "  #{m["src_path"]} ← #{m["dst_path"]}" if @verbose
          cmd = "ln -s"
          should_link = if File.file?(m["dst_path"])
            dst_real_path = Pathname.new(m["dst_path"]).realpath.to_s
            if dst_real_path != m["src_path"]
              cmd << " -f"
              quiz "The destination file `#{m["dst_path"]}` already " +
                   "exists. Overwrite"
            else
              false
            end
          elsif File.directory?(m["dst_path"])
            if quiz "The destination file `#{m["dst_path"]}` is a " +
                    "directory. Delete it"
              exec_cmd("rm -Rf #{m["dst_path"]}",
                       as_su: !existing_dir(File.dirname(m["dst_path"])))
            end
          else
            # Link does not exist yet.
            true
          end

          if should_link
            cmd << " \"#{m["src_path"]}\" \"#{m["dst_path"]}\""
            exec_cmd(cmd,
                     :as_su => !existing_dir(File.dirname(m['dst_path'])))
          end
        end
      },
      lambda { |elem| # Change permissions of the instantiated files (if specified).
        if elem.has_key?('perms')
          elem['fs_maps'].each do |m|
            say "Changing permissions of #{m['src_path']} to #{elem['perms']}" if @verbose
            exec_cmd("chmod -R \"#{elem['perms']}\" \"#{m['src_path']}\"",
                     :as_su => !File.owned?(m['src_path']))
          end
        end
      }
    ]
  end

  #
  # Return a data structure containing the commands that can be specified in
  # the meta file.
  #
  # The data structure defines:
  # - The available command types (`available_commands.keys`).
  # - (Optionally) A validator that can be used to validate type-specific
  #   validation rules.
  # - The command executor: A `Lambda` containing the code used for executing
  #   that command.
  #
  def available_commands
    { 'git_sync' => {
        'validator' => lambda { |spec|
          if spec.has_key?('dst')
            spec['dst'] = File.expand_path(spec['dst'])
          end
          status   = spec.has_key?('repo')
          status &&= spec.has_key?('dst')
        },
        'executor' => lambda { |spec|
          if File.directory?(spec['dst'])
            FileUtils.cd(spec['dst']) { git_pull }
          else
            git_clone(spec['repo'], spec['dst'])
          end
        }
      }
    }
  end

end
