class Fizzy::Caller

  def self.value(name, depth=1)
    RubyVM::DebugInspector.open do |inspector|
      eval(name.to_s, inspector.frame_binding(depth + 2))
    end
  end

  def self.info(depth=1)
    parse_caller(caller(depth + 2).first)
  end

  def self.method_name(depth=1)
    parse_caller(caller(depth + 2).first)[:method]
  end

  def self.parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file   = Regexp.last_match[1]
      line   = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      {file: file, line: line, method: method}
    end
  end

end
