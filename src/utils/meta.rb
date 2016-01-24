module Fizzy::Utils

  #
  # Return the normalized and validated meta object.
  #
  # Be sure to call `setup_vars` before calling this method.
  #
  def get_meta(meta_path, vars_path, elems_base_path, verbose) # {{{
    say 'Getting meta informations.', :blue

    meta = YAML.load(File.read(meta_path))
    meta["all_elems_count"] = meta['elems'].count

    # Step 1: Normalize elements ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    elem_erb_excluded_fields = ['only']

    meta['elems'] = [] unless meta.has_key? 'elems'

    meta['elems'] = meta['elems'].each_with_index.collect do |elem, idx|
      elem_identifier = elem['name'] || "src = #{elem['src']}"
      info("\nElement: ", elem_identifier) if verbose

      # Step 1.1: Validate `only` and determine if the element is selected.
      if elem.has_key?('only') && !elem['only'].is_a?(Hash)
        error "The configuration element `#{elem_identifier}` has invalid " +
              "`only`: it's not a `Hash`."
      end
      selected = selected_by_only?(elem['only'], verbose)

      # Step 1.2: Pre-process strings with ERB.
      if selected
        elem.each do |k, v|
          unless elem_erb_excluded_fields.include? k
            elem[k] = ERB.new(v).result(binding)
          end
        end
      end

      # Step 1.3: Validate and normalize `name`, `src`, `dst`, `fs_maps`.
      if selected
        unless elem.has_key?('src')
          error "Element `#{elem_identifier}` doesn't contain `src`."
        end
        unless elem.has_key?('name')
          elem['name'] = elem['src']
        end
        unless elem.has_key?('dst')
          error "Element `#{elem_identifier}` doesn't contain `dst`."
        end
        elem['fs_maps'] = []
      end

      selected ? elem : nil
    end.compact

    # Step 1.4: For each active elem, match the `src` field against the
    #           filesystem and determine filesystem mapping (`fs_maps`).
    meta['elems'].each do |elem|
      found = false

      Find.find(elems_base_path).select {|ebp| File.file? ebp }
          .each do |subfile_path|
        subfile_rel_path = Pathname.new(subfile_path).relative_path_from(
          Pathname.new(elems_base_path)).to_s
        if md = Regexp.new(elem['src']).match(subfile_rel_path.gsub(/\.tt$/, ''))
          found = true
          dst_path = elem['dst'].gsub(/<([0-9]+)>/) do
            idx = Integer($1)
            unless (1..md.length) === idx
              error "Invalid 'dst' for element `#{elem['name']}`: nothing " +
                    "captured at index `#{idx}`."
            else
              md[idx]
            end
          end
          elem['fs_maps'] << {
            'src_path' => File.expand_path(subfile_path),
            'dst_path' => File.expand_path(dst_path)
          }
        end
      end

      unless found
        warning "Inconsistency found for elem `#{elem['name']}`: no file " +
                "matches src: `#{elem['src']}`."
      end
    end

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    # Step 2: Normalize commands ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    command_excluded_erb_fields = ['only']

    meta['commands'] = [] unless meta.has_key? 'commands'

    meta['commands'] = meta['commands'].each_with_index.collect do |spec, idx|
      spec['name'] ||= "type = #{spec['type']}, index = #{idx}"
      info("\nCommand: ", spec['name']) if verbose

      # Step 2.1: Validate 'only' and determine if the command is selected.
      if spec.has_key?('only') && !spec['only'].is_a?(Hash)
        error "The command `#{spec['name']}` has invalid `only`: it's not " \
              'a `Hash`.'
      end
      selected = selected_by_only?(spec['only'], verbose)

      if selected

        # Step 2.2: Pre-process strings with ERB.
        spec.each do |key, value|
          unless command_excluded_erb_fields.include? key
            spec[key] = ERB.new(value).result(binding)
          end
        end

        # Step 2.3: Validate `type`, `validator`, `executor`.
        if !spec.has_key?('type') ||
           !available_commands.keys.include?(spec['type'])
          error "The command `#{spec['name']}` has invalid `type`: it's " \
                "not in `#{available_commands.keys}`."
        end
        command = available_commands[spec['type']]
        if command.has_key?('validator') && !command['validator'].is_a?(Proc)
          error "Invalid validator for command `#{spec['name']}`: if " \
                "provided it should be a `Proc`."
        end
        if !command.has_key?('executor') || !command['executor'].is_a?(Proc)
          error "Invalid executor for command `#{spec['name']}`: it should " \
                'be a `Proc`.'
        end

        # Step 2.4: Use type-specific validator if it's defined.
        if command.has_key?('validator') && (
             !command['validator'].is_a?(Proc) ||
             !command['validator'].call(spec)
           )
          error "The validator for command `#{spec['name']}` didn't pass."
        end
      end

      selected ? spec : nil
    end.compact

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    # Build the list of excluded files (needed by Thor's `directory()`).
    all_files = Set.new Find.find(elems_base_path).select { |f| File.file? f }
    src_paths = Set.new(
      meta['elems'].collect_concat do |elem|
        elem['fs_maps'].collect { |m| m['src_path'] }
      end
    )
    vars_files = Dir.glob(File.join(vars_path, '*'), File::FNM_DOTMATCH)
    meta['system_files'] = Set.new(vars_files << meta_path)
    meta['excluded_files'] = all_files - src_paths - meta['system_files']
    meta['all_files_count'] = all_files.count

    meta
  end # }}}

  #
  # Return whether the provided `only` specification is evaluated as an allows
  # and not as a denies.
  #
  def selected_by_only?(only, verbose) # {{{
    unless only
      selected = true
      info(' ↳ ', "#{set_color('✔', :green)} (`only` is empty).") if verbose
    else
      wants_features = only.has_key?('features')
      wants_vars     = only.has_key?('vars')

      feat_ok = if wants_features
                  only['features'].any? do |feature|
                    case feature
                    when Array
                      feature.all? { |f| has_feature? f }
                    else
                      has_feature? feature
                    end
                  end
                else
                  true
                end
      vars_ok = wants_vars ?
          only['vars'].any? { |var| !get_var(var).nil? } :
          true

      selected   = !wants_features && !wants_vars
      selected ||= (feat_ok && vars_ok)

      if selected && verbose
        info ' ↳ ', "#{set_color('✔', :green)} (`only` is present and " +
                    'satisfied).'
      end
    end

    if !selected && verbose
      info ' ↳ ', "#{set_color('✘', :red)} (`only` is present and didn't " +
                  'match).'
    end

    selected
  end # }}}

end
