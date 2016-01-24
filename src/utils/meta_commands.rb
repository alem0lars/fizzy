# Manage commands declared in the meta file.
#
module Fizzy::MetaCommands

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
    { "git_sync" => {
        "validator" => lambda { |spec|
          if spec.has_key?("dst")
            spec["dst"] = File.expand_path(spec["dst"])
          end
          status   = spec.has_key?("repo")
          status &&= spec.has_key?("dst")
        },
        "executor" => lambda { |spec|
          if File.directory?(spec["dst"])
            FileUtils.cd(spec["dst"]) { git_pull }
          else
            git_clone(spec["repo"], spec["dst"])
          end
        }
      }
    }
  end
end
