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
      },
      "download" => {
        "validator" => lambda { |spec|
          # 1. Validate.
          status   = spec.has_key?("url")
          status &&= spec.has_key?("dst")
          # 2. Normalize.
          if status
            spec["url"] = URI(spec["url"])
            spec["dst"] = Pathname.new(spec["dst"]).expand_path
          end
          status
        },
        "executor" => lambda { |spec|
          res = Net::HTTP.get_response(spec["url"])
          if res.is_a?(Net::HTTPSuccess)
            # TODO atm it requires the current user has write access.
            #      refactor when a more robust permission mgmt is implemented.
            FileUtils.mkdir_p(spec["dst"].dirname)
            spec["dst"].write(res.body)
          else
            error("Network error: cannot retrieve `#{spec["url"]}`.")
          end
        }
      }
    }
  end

end
