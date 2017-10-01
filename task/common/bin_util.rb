def foreach_source_file
  $cfg[:sources].map do |src_file_name|
    src_file_path = Pathname.new(src_file_name)
    if src_file_path.absolute?
      src_file_name = src_file_path.basename(src_file_path.extname)
    else
      src_file_path = $cfg[:paths][:src].join("#{src_file_path}.rb")
    end
    src_file_name = src_file_name.to_s
    src_file_content = src_file_path.read

    yield src_file_name, src_file_path, src_file_content
  end
end

def generate_section_separator(section_title)
  section_title = titleize_file_name(section_title, inverted: true)
  sep_left    = "# "
  sep_right   = " #{section_title} ──"
  sep_padding = "─" * (80 - sep_left.length - sep_right.length)
  "#{sep_left}#{sep_padding}#{sep_right}"
end

def write_bin(title, content, newlines: [0, 0], mode: "a")
  $cfg[:paths][:bin].open(mode) do |bin_file|
    info("Filling binary with: #{title}", indent: 1) if title && !title.empty?
    content = "" if content.nil?
    if newlines.is_a?(Array) && newlines.length == 2
      content = ("\n" * newlines.first) + content + ("\n" * newlines.last)
    elsif newlines.is_a?(Fixnum)
      content = content + ("\n" * newlines)
    else
      error("Invalid argument `newlines`: expected to be a 2-ple or number")
    end
    bin_file.write(content)
  end
end

def cleanup_bin
  # Remove old binary.
  $cfg[:paths][:old_bin].unlink if $cfg[:paths][:old_bin].file?
  # Remove link.
  $cfg[:paths][:bin_rb].unlink  if $cfg[:paths][:bin_rb].file?
  # Backup current binary.
  $cfg[:paths][:bin].rename($cfg[:paths][:old_bin]) if $cfg[:paths][:bin].file?
end
