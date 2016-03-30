# Utilities to interact with the filesystem.
#
module Fizzy::Filesystem

  include Fizzy::IO
  include Fizzy::Execution

  # Find a YAML file prefixed by `path` (guess extension name).
  #
  def find_yaml_path(path)
    if File.file?(path)
      path
    else
      %w(yml yaml).map do |ext|
        "#{path}.#{ext}" if File.file?("#{path}.#{ext}")
      end.compact.first
    end
  end

  # Check if the provided `path` is an existing directory.
  #
  # If `writable` is true, also check if `path` points to a writable
  # directory.
  #
  def existing_dir(path, writable: true)
    dir_path = path
    dir_path = File.dirname(dir_path) until File.directory?(dir_path)
    (writable && !File.writable?(dir_path)) ? nil : dir_path
  end

  # Return an object (`OpenStruct`), which contains all of the well-known
  # paths.
  #
  # Before adding a path, some validations are executed to ensure that path
  # points to a correct thing.
  #
  # You can skip some validations and filling some paths:
  # - `valid_cfg`: If `false` don't validate and fill paths related to the
  #                configuration.
  # - `valid_inst`:
  #   - If `false` don't validate and fill paths related to the configuration
  #     instances.
  #   - If `true`, be sure to provide the argument `cur_inst_name`, which
  #     should contain the name of the current instance (the instance that
  #     should be used).
  #
  def prepare_storage(root_path,
                      valid_meta: true, valid_cfg: true, valid_inst: true,
                      meta_name: nil, cur_cfg_name: nil, cur_inst_name: nil,
                      readonly: false)
    root_path = Pathname.new(root_path).expand_path

    # Paths based on internal conventions.
    parent_path = root_path.dirname

    cfg_path = root_path.join("cfg")
    cur_cfg_path = cfg_path.join(cur_cfg_name) if cur_cfg_name
    cur_cfg_vars_path = cur_cfg_path.join("vars") if cur_cfg_path
    cur_cfg_meta_path = find_yaml_path(cur_cfg_path.join(meta_name)) if cur_cfg_path && meta_name

    inst_path = root_path.join("inst")
    cur_inst_path = inst_path.join(cur_inst_name) if cur_inst_name
    cur_inst_vars_path = cur_inst_path.join("vars") if cur_inst_path
    cur_inst_meta_path = find_yaml_path(cur_inst_path.join(meta_name)) if cur_inst_path && meta_name

    # Validate `root_path`.
    if !root_path.directory? && !parent_path.writable?
      error("Cannot create directory: `#{root_path}`.")
    end
    if root_path.file?
      if quiz("`#{root_path}` already exists but is a regular file. Remove")
        exec_cmd("rm #{Shellwords.escape(root_path)}",
                 as_su: File.owned?(root_path))
      else
        error("File `#{root_path}` already exists but is needed as fizzy " +
              "root directory. Aborting.")
      end
    end

    if !valid_cfg && root_path.directory? && !root_path.writable?
      error("No write permissions in Fizzy storage at path `#{root_path}`.")
    end

    if valid_cfg
      unless root_path.directory?
        error("The Fizzy root directory `#{root_path}` doesn't exist " +
              "(maybe you need to run: `fizzy cfg sync`).")
      end
      if cur_cfg_path.nil? || !cur_cfg_path.directory? || !(readonly || cur_cfg_path.writable?)
        error("The current configuration `#{cur_cfg_name}` is invalid: " +
              "it's not a valid (writable) directory.")
      end
      if valid_meta && (cur_cfg_meta_path.nil? || !cur_cfg_meta_path.file?)
        error("The meta file path `#{cur_cfg_meta_path}` is invalid.")
      end
      if cur_cfg_vars_path.nil? || !cur_cfg_vars_path.directory?
        error("The variables directory `#{cur_cfg_vars_path}` is invalid.")
      end
    end

    if valid_inst
      unless root_path.directory?
        error("The Fizzy root directory `#{root_path}` doesn't exist " +
              "(maybe you need to run: `fizzy cfg sync`).")
      end
      if cur_inst_path.nil? || !cur_inst_path.directory? || !(readonly || cur_inst_path.writable?)
        error("The current instance `#{cur_inst_name}` is invalid: it's " +
              "not a valid (writable) directory.")
      end
      if valid_meta && (cur_inst_meta_path.nil? || !cur_inst_meta_path.file?)
        error("The meta file path `#{cur_inst_meta_path}` is invalid.")
      end
      if cur_inst_vars_path.nil? || !cur_inst_vars_path.directory?
        error("The variables directory `#{cur_inst_vars_path}` is invalid.")
      end
    end

    # Create non-existing internal directories.
    FileUtils.mkdir_p(root_path) unless root_path.directory?
    [cfg_path, inst_path].each do |dir_path|
      unless dir_path.directory?
        FileUtils.mkdir_p(dir_path)
        exec_cmd("chmod a+w #{Shellwords.escape(dir_path)}",
                 as_su: File.owned?(dir_path))
      end
    end
    if cur_inst_path && !cur_inst_path.directory?
      FileUtils.mkdir_p(cur_inst_path)
    end

    # Return the known storage paths.
    OpenStruct.new(
      root:          root_path,
      cfg:           cfg_path,
      cur_cfg:       cur_cfg_path,
      cur_cfg_vars:  cur_cfg_vars_path,
      cur_cfg_meta:  cur_cfg_meta_path,
      inst:          inst_path,
      cur_inst:      cur_inst_path,
      cur_inst_vars: cur_inst_vars_path,
      cur_inst_meta: cur_inst_meta_path)
  end

end
