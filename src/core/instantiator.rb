class Fizzy::Instantiator
  include Fizzy::IO

  attr_reader :src_dir_path, :instance_dir_path
  attr_reader :renderer, :regexp, :glob
  private :renderer, :regexp, :glob

  def initialize(src_dir_path, instance_dir_path, context, **options)
    must "source directory", src_dir_path, be: Pathname
    must "instance directory", instance_dir_path, be: Pathname

    @src_dir_path      = src_dir_path.expand_path
    @instance_dir_path = instance_dir_path.expand_path

    validator = Fizzy::Template::Context::Validator.new # TODO specific validator
    @renderer = Fizzy::Template::Renderer.new(context, validator: validator)

    @regexp = options.delete(:regexp) || /.+/
    @glob   = options.delete(:glob) || %w(** *)
  end

  #
  # Cleanup unused old instance files that don't correspond to source files
  # anymore.
  #
  # TODO test
  #
  def cleanup_instance
    src_file_paths_ = src_file_paths
    instance_file_paths.each do |instance_file_path|
      instance_file_path.unlink unless src_file_paths_.include?
    end
  end

  #
  # Perform instantiation of templates present in `src_dir_path` into concrete
  # files.
  #
  # TODO test
  #
  def instantiate
    metadata = src_file_paths.compact.map do |src_file_path|
      src_file_rel_path         = src_file_path.to_s.gsub(src_dir_path.to_s, ".")
      instance_file_path        = instance_dir_path.join(src_file_rel_path)
      src_file_content          = src_file_path.read
      instance_file_content     = renderer.render(src_file_content)
      old_instance_file_content = if instance_file_path.file?
                                    instance_file_path.read
                                  end
      puts "src_dir_path=#{src_dir_path} src_file_path=#{src_file_path} src_file_rel_path=#{src_file_rel_path} instance_dir_path=#{instance_dir_path} instance_file_path=#{instance_file_path}"

      diff = if old_instance_file_content
               generator = Fizzy::Diff::Generator.new(old_instance_file_content,
                                                      instance_file_content)
               generator.generate_diff
             end

      if diff.nil? # file didn't exist already
        info "Creating new instance file #{✏ src_file_rel_path}"
      elsif diff.empty? # file was the same
        info "Skipping instantiation of file #{✏ src_file_rel_path}: content is the same."
        next
      else
        # file was different
        info "Computed difference between old and new content of #{✏ src_file_rel_path}:\n#{Fizzy::Diff::Generator.diff_to_str(diff)}"

        if ask "Do you want to apply changes"
          info "Applying changes to instance file #{✏ src_file_rel_path}"
        else
          info "Skipping file #{✏ src_file_rel_path}: keeping old content."
          next
        end
      end

      {
        src_file_path:     src_file_path,
        src_file_rel_path: src_file_rel_path,
        diff:              diff,
        result:            instance_file_path.write(instance_file_content),
      }
    end.compact

    instance_dir_path.join("metadata.yml").write(metadata)

    metadata
  end

  # ──────────────────────────────────────────────────────────────── FS utils ──

  private def instance_file_paths
    Pathname.glob(instance_dir_path.join("**", "*"))
  end

  private def src_file_paths
    Pathname.glob(src_dir_path.join(*@glob)).select do |src_file_path|
      !src_file_path.directory? && (!regexp || regexp.match(src_file_path.to_s))
    end
  end

end
