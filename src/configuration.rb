Fizzy::CFG = OpenStruct.new

# Default editor.
Fizzy::CFG.editor = ENV["EDITOR"] || "vim"

# The operating-system which fizzy is running on.
Fizzy::CFG.os = case RUBY_PLATFORM
                when /darwin/ then :osx
                when /linux/  then :linux
                else               :windows
                end

# Default fizzy root directory (holding all of the fizzy stuff).
Fizzy::CFG.default_fizzy_dir = Pathname.new(
  ENV["FIZZY_DIR"] ||
  case Fizzy::CFG.os
  when :linux   then "/usr/share/fizzy"
  when :osx     then "~/Library/Application Support/fizzy"
  when :windows then "~/fizzy"
  end
).expand_path

# Default meta file name.
Fizzy::CFG.default_meta_name = "meta.yml"
