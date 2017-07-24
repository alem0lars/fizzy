OptionParser.accept(Pathname) do |s,|
  begin
    Pathname.new(s) if s
  rescue ArgumentError
    raise OptionParser::InvalidArgument, s
  end
end
