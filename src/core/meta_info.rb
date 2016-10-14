# Access informations declared in the meta file.
#
module Fizzy::MetaInfo

  include Fizzy::IO
  include Fizzy::Vars

  # Return the normalized and validated meta object.
  #
  # Be sure to call `setup_vars` before calling this method.
  #
  def get_meta(meta_path, vars_path, elems_base_path, verbose)
    tell("Getting meta informations.", :blue)

    begin
      meta = YAML.load(File.read(meta_path)).deep_symbolize_keys
    rescue Psych::SyntaxError => exc
      error("Failed to parse meta file: `#{meta_path}`. " +
            "Reason: `#{exc.message}`.")
    end

    meta[:all_elems_count] = meta[:elems].count

    # ──────────────────────────────────────────────────────────────────────────
    # ☞ Step 1: Normalize elements

    elem_erb_excluded_fields = %i(only)

    meta[:elems] = [] unless meta.has_key?(:elems)

    meta[:elems] = meta[:elems].each_with_index.collect do |elem, idx|
      elem_identifier = elem[:name] || "src = #{elem[:src]}"
      info("\nElement: ", elem_identifier) if verbose

      # Step 1.1: Validate `only` and determine if the element is selected.
      if elem.has_key?(:only) && !(elem[:only].is_a?(Hash) || elem[:only].is_a?(String))
        error("The configuration element `#{elem_identifier}` has invalid " +
              "`only`: it's not a `Hash`.")
      end
      selected = selected_by_only?(elem[:only], verbose)

      # Step 1.2: Pre-process strings with ERB.
      if selected
        elem.each do |k, v|
          unless elem_erb_excluded_fields.include?(k)
            elem[k] = ERB.new(v).result(binding)
          end
        end
      end

      # Step 1.3: Validate and normalize `name`, `src`, `dst`, `fs_maps`.
      if selected
        unless elem.has_key?(:src)
          error("Element `#{elem_identifier}` doesn't contain `src`.")
        end
        elem[:name] = elem[:src] unless elem.has_key?(:name)
        unless elem.has_key?(:dst)
          error("Element `#{elem_identifier}` doesn't contain `dst`.")
        end
        elem[:fs_maps] = []
      end

      selected ? elem : nil
    end.compact

    # Step 1.4: For each active elem, match the `src` field against the
    #           filesystem and determine filesystem mapping (`fs_maps`).
    meta[:elems].each do |elem|
      found = false

      Find.find(elems_base_path)
          .select { |ebp| File.file?(ebp) }
          .each do |subfile_path|

        subfile_rel_path = Pathname.new(subfile_path).relative_path_from(
                           Pathname.new(elems_base_path)).to_s
        if md = Regexp.new(elem[:src]).match(subfile_rel_path.gsub(/\.tt$/, ''))
          found = true
          dst_path = elem[:dst].gsub(/<([0-9]+)>/) do
            idx = Integer($1)
            unless (1..md.length) === idx
              error("Invalid `dst` for element `#{elem[:name]}`: nothing " +
                    "captured at index `#{idx}`.")
            else
              md[idx]
            end
          end
          elem[:fs_maps] << {
            src_path: Pathname.new(subfile_path).expand_path,
            dst_path: Pathname.new(dst_path).expand_path
          }
        end
      end

      unless found
        warning("Inconsistency found for elem `#{elem[:name]}`: no file " +
                "matches src: `#{elem[:src]}`.")
      end
    end

    # ──────────────────────────────────────────────────────────────────────────
    # ☞ Step 2: Normalize commands

    command_excluded_erb_fields = [:only]

    meta[:commands] = [] unless meta.has_key?(:commands)

    meta[:commands] = meta[:commands].each_with_index.collect do |spec, idx|
      spec[:type] = spec[:type].to_sym
      spec[:name] ||= "type = #{spec[:type]}, index = #{idx}"
      info("\nCommand: ", spec[:name]) if verbose

      selected = selected_by_only?(spec[:only], verbose)

      if selected

        # Step 2.2: Pre-process strings with ERB.
        spec.each do |key, value|
          unless command_excluded_erb_fields.include?(key)
            if value.is_a?(String)
              spec[key] = ERB.new(value).result(binding)
            end
          end
        end

        # Step 2.3: Validate `type`, `validator`, `executor`.
        if !spec.has_key?(:type) ||
           !available_commands.keys.include?(spec[:type])
          error("The command `#{spec[:name]}` has invalid `type`: it's " +
                "not in `#{available_commands.keys}`.")
        end
        command = available_commands[spec[:type]]
        if command.has_key?(:validator) && !command[:validator].is_a?(Proc)
          error("Invalid validator for command `#{spec[:name]}`: if " +
                "provided it should be a `Proc`.")
        end
        if !command.has_key?(:executor) || !command[:executor].is_a?(Proc)
          error("Invalid executor for command `#{spec[:name]}`: it should " +
                "be a `Proc`.")
        end

        # Step 2.4: Use type-specific validator if it's defined.
        if command.has_key?(:validator) && (
             !command[:validator].is_a?(Proc) ||
             !command[:validator].call(spec)
           )
          error("The validator for command `#{spec[:name]}` didn't pass.")
        end
      end

      selected ? spec : nil
    end.compact

    # ──────────────────────────────────────────────────────────────────────────

    # Build the list of excluded files (needed by thor's `directory(..)`).
    all_files = Set.new(Find.find(elems_base_path)
                            .map{|f| Pathname.new(f).expand_path}
                            .select{|f| f.file?})
    src_paths = Set.new(
      meta[:elems].collect_concat do |elem|
        elem[:fs_maps].map{|m| m[:src_path]}
      end)
    vars_files = Pathname.glob(vars_path.join("*"), File::FNM_DOTMATCH)
    meta[:system_files]    = Set.new(vars_files << meta_path)
    meta[:excluded_files]  = all_files - src_paths - meta[:system_files]
    meta[:all_files_count] = all_files.count

    meta
  end

  # Return whether the provided `only` specification is evaluated as an allow
  # (and not as a deny).
  #
  def selected_by_only?(only, verbose)
    selected = if only.is_a?(Hash) # Evaluate `only` has a Hash.
      wants_features = only.has_key?(:features)
      wants_vars     = only.has_key?(:vars)
      if wants_features
        feat_ok = only[:features].any? do |feature|
          case feature
            when Array then feature.all?{|f| has_feature?(f)}
            else            has_feature?(feature)
          end
        end
      else
        feat_ok = true
      end
      vars_ok = wants_vars ?
          only[:vars].any?{|var| !get_var(var, single_match: false).nil?} :
          true

      (!wants_features && !wants_vars) || (feat_ok && vars_ok)
    elsif only.is_a?(String) # Evaluate `only` has a logic expression.
      Fizzy::LogicParser.new.parse(self, only)
    elsif only.nil? # By default, it's selected.
      selected = true
    else
      error("`#{spec[:name]}` has invalid `only`.")
    end

    if verbose
      if selected
        if only.nil?
          info(" ↳ ", "#{✔} (`only` is empty).")
        else
          info(" ↳ ", "#{✔} (`only` is present and satisfied).")
        end
      else
        info(" ↳ ", "#{✘} (`only` didn't match).")
      end
    end

    selected
  end

end
