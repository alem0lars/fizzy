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
