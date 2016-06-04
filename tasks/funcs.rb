# ──────────────────────────────────────────────────────────────────────────────
# ☞ Command-line arguments

def std_args
  args = ARGV[1..-1]
  args.each { |a| task a.to_sym do ; end } # Prevent unknown task errors.
  args
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ Logging

def info(msg, indent: 0, success: false)
  puts(("\t" * indent) + "☞ " + "\e[#{success ? 32 : 34}m#{msg}\e[0m")
end

def error(msg)
  puts("\e[31m☠ Error: #{msg}\e[0m")
  exit(-1)
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ `String`s manipulation

def titleize_file_name(file_name)
  file_name.split("/").join(" → ").
            split("_").join(" ").
            split(/(\s+(?:\S+\s+)?)/).map { |e| e.capitalize }.join
end

# ──────────────────────────────────────────────────────────────────────────────
# ☞ `Hash`s manipulation

def deep_merge(first, second)
  merger = proc do |key, v1, v2|
    Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
  end
  first.merge(second, &merger)
end

def symbolize(obj)
  return obj.reduce({}) do |memo, (k, v)|
    memo.tap { |m| m[k.to_sym] = symbolize(v) }
  end if obj.is_a? Hash

  return obj.reduce([]) do |memo, v|
    memo << symbolize(v); memo
  end if obj.is_a? Array

  obj
end
