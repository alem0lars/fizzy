# Filesystem

module Fizzy::Utils

  #
  # Find a YAML file prefixed by `path` (guess extension name).
  #
  def find_yaml_path(path)
    if File.file?(path)
      path
    else
      %w(yml yaml).map do |ext|
        "#{path}.#{ext}" if File.file? "#{path}.#{ext}"
      end.compact.first
    end
  end

  #
  # Check if the provided `path` is an existing directory.
  #
  # If `writable` is true, also check if `path` points to a writable
  # directory.
  #
  def existing_dir(path, writable: true) # {{{
    dir_path = path
    dir_path = File.dirname(dir_path) until File.directory?(dir_path)
    (writable && !File.writable?(dir_path)) ? nil : dir_path
  end # }}}

  #
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
                      meta_name: nil, cur_cfg_name: nil, cur_inst_name: nil)
    root_path = File.expand_path(root_path)

    # Paths based on internal conventions.
    parent_path = File.dirname(root_path)

    cfg_path = File.join(root_path, 'cfg')
    cur_cfg_path = cur_cfg_name ? File.join(cfg_path, cur_cfg_name) : nil
    cur_cfg_vars_path = cur_cfg_path ? File.join(cur_cfg_path, 'vars') : nil
    cur_cfg_meta_path = cur_cfg_path && meta_name ? find_yaml_path(File.join(cur_cfg_path, meta_name)) : nil

    inst_path = File.join(root_path, 'inst')
    cur_inst_path = cur_inst_name ? File.join(inst_path, cur_inst_name) : nil
    cur_inst_vars_path = cur_inst_path ? File.join(cur_inst_path, 'vars') : nil
    cur_inst_meta_path = cur_inst_path && meta_name ? find_yaml_path(File.join(cur_inst_path, meta_name)) : nil

    # Validate `root_path`.
    if !File.directory?(root_path) && !File.writable?(parent_path)
      error "Cannot create directory: `#{root_path}`."
    end
    if File.file?(root_path)
      if quiz "`#{root_path}` already exists but is a regular file. Remove?"
        exec_cmd "rm #{root_path}", as_su: File.owned?(root_path)
      else
        error "File `#{root_path}` already exists but is needed as fizzy " \
              'root directory. Aborting.'
      end
    end
    if !valid_cfg && File.directory?(root_path) && !File.writable?(root_path)
      error "No write permissions in Fizzy storage at path `#{root_path}`."
    end

    if valid_cfg
      unless File.directory?(root_path)
        error "The Fizzy root directory `#{root_path}` doesn't exist " \
              '(maybe you need to run: `fizzy cfg sync`).'
      end
      if !File.directory?(cur_cfg_path) || !File.writable?(cur_cfg_path)
        error "The current configuration `#{cur_cfg_name}` is invalid: " \
              "it's not a valid directory."
      end
      if valid_meta && !File.file?(cur_cfg_meta_path)
        error "The meta file path `#{cur_cfg_meta_path}` is invalid."
      end
      unless File.directory?(cur_cfg_vars_path)
        error "The variables directory `#{cur_cfg_vars_path}` is invalid."
      end
    end

    if valid_inst
      unless File.directory?(root_path)
        error "The Fizzy root directory `#{root_path}` doesn't exist " \
              '(maybe you need to run: `fizzy cfg sync`).'
      end
      if !File.directory?(cur_inst_path) || !File.writable?(cur_inst_path)
        error "The current instance `#{cur_inst_name}` is invalid: it's " \
              'not a valid directory.'
      end
      if valid_meta && !File.file?(cur_inst_meta_path)
        error "The meta file path `#{cur_inst_meta_path}` is invalid."
      end
      unless File.directory?(cur_inst_vars_path)
        error "The variables directory `#{cur_inst_vars_path}` is invalid."
      end
    end

    # Create non-existing internal directories.
    FileUtils.mkdir_p(root_path) unless File.directory?(root_path)
    [cfg_path, inst_path].each do |dir_path|
      unless File.directory?(dir_path)
        FileUtils.mkdir_p(dir_path)
        exec_cmd("chmod a+w \"#{dir_path}\"", as_su: File.owned?(dir_path))
      end
    end
    if cur_inst_path && !File.directory?(cur_inst_path)
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
