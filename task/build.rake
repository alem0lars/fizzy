desc "Build Fizzy"
task :build do
  info "Build started"

  # ☞ Initial cleanup.
  cleanup_bin

  # ☞ Build grammars.
  build_grammars

  # ☞ Write preamble.
  write_bin("HashBang", $cfg[:hashbang], newlines: 2)
  write_bin("Header",   $cfg[:header],   newlines: 1)

  # Write module declarations.
  regexp = /^\s*(module|class)\s+([a-zA-Z0-9_]+(?:(?:[:][:])?[a-zA-Z0-9_])*)\s*$/
  section_name = "Modules declaration"
  separator = generate_section_separator(section_name)
  write_bin("Separator for section `#{section_name}`", "#{separator}", newlines: [1, 2])
  foreach_source_file do |src_file_name, _, src_file_content|
    src_file_content.split("\n").map { |line| line.match(regexp) }.map do |md|
      next unless md
      components = md[2].split("::")
      components.pop if md[1] == "class"
      components.each_with_index.map do |_, index|
        components[0..index].join("::")
      end
    end
  end.flatten.compact.uniq.each do |mod|
    write_bin("Module declaration `#{mod}`", "module #{mod}; end\n")
  end

  # ☞ Write source files content.
  foreach_source_file do |src_file_name, src_file_path, src_file_content|
    separator = generate_section_separator(src_file_name)
    write_bin("Separator for section `#{src_file_name}`", "#{separator}", newlines: [1, 2])
    write_bin("Content of file `#{src_file_name}`",
              ErbFromOStruct.new({ build_cfg: $cfg }).render(src_file_content))
  end

  # ☞ Cleanup temporary files.
  $cfg[:sources].select { |name| name.to_s =~ /^#{$cfg[:paths][:tmp].to_s}/ }
    .each { |tmp_file| tmp_file.delete }

  # ☞ Set executable permissions.
  $cfg[:paths][:bin].chmod 0775

  # ☞ Link to a `.rb` file (mainly used for testing purposes).
  $cfg[:paths][:bin_rb].unlink if $cfg[:paths][:bin_rb].file?
  FileUtils.cp($cfg[:paths][:bin], $cfg[:paths][:bin_rb])

  info "Build successfully completed", success: true
end
