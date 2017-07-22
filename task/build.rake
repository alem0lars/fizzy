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

  # ☞ Write source files content.
  $cfg[:sources].each do |src_file_name|
    src_file_path = Pathname.new(src_file_name)
    if src_file_path.absolute?
      src_file_name = src_file_path.basename(src_file_path.extname)
    else
      src_file_path = $cfg[:paths][:src].join("#{src_file_path}.rb")
    end
    src_file_name = src_file_name.to_s

    section_title = titleize_file_name(src_file_name, inverted: true)
    sep_left    = "# "
    sep_right   = " #{section_title} ──"
    sep_padding = "─" * (80 - sep_left.length - sep_right.length)
    write_bin("Separator for section `#{src_file_name}`",
              "#{sep_left}#{sep_padding}#{sep_right}",
              newlines: [1, 2])
    write_bin("Content of file `#{src_file_name}`",
              ErbFromOStruct.new({ build_cfg: $cfg }).render(src_file_path.read))
  end

  # ☞ Cleanup temporary files.
  $cfg[:sources].select { |name| name.to_s =~ /^#{$cfg[:paths][:tmp].to_s}/ }
    .each { |tmp_file| tmp_file.delete }

  # ☞ Set executable permissions.
  $cfg[:paths][:bin].chmod 0775

  # ☞ Link to a `.rb` file (mainly used for testing purposes).
  $cfg[:paths][:bin_rb].unlink if $cfg[:paths][:bin_rb].symlink?
  $cfg[:paths][:bin_rb].make_symlink $cfg[:paths][:bin]

  info "Build successfully completed", success: true
end
