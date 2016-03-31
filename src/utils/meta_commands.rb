# Manage commands declared in the meta file.
#
module Fizzy::MetaCommands

  include Fizzy::Git

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
          spec["dst"] = Pathname.new(spec["dst"]).expand_path if spec.has_key?("dst")
          status   = spec.has_key?("repo")
          status &&= spec.has_key?("dst")
        },
        "executor" => lambda { |spec|
          if spec["dst"].directory?
            FileUtils.cd(spec["dst"]) { git_pull }
          else
            git_clone(spec["repo"], spec["dst"])
          end
        }
      }
    }
  end

end
