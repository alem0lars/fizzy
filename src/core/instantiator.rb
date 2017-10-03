class Fizzy::Instantiator
  attr_reader :src_dir_path, :dst_dir_path, :renderer, :include_regexp

  def initialize(src_dir_path, dst_dir_path, context, validator, **kwargs)
    must "source directory", src_dir_path, be: Pathname
    must "destination directory", dst_dir_path, be: Pathname

    @src_dir_path = src_dir_path
    @dst_dir_path = dst_dir_path
    @renderer = Fizzy::Template::Renderer.new(context, validator)
    @include_regexp = kwargs[:include_regexp] if kwargs.has? :include_regexp
  end

  def instantiate
    Pathname.glob(src_dir_path.join("**", "*")).map do |src_file_path|
      src_file_path if !include_regexp || include_regexp.match(src_file_path)
    end.compact.map do |src_file_path|
      src_file_rel_path = src_file_path.relative_path_from(src_dir_path)
      dst_file_path = dst_file_path.join(src_file_rel_path)
      src_file_content = src_file_path.read
      dst_file_content = renderer.render(src_file_content)
      # TODO if file already exists compute diff and ask user if it is ok
      # TODO create destination file
    end
  end
end
