#
# Fizzy command to show how to use fizzy.
#
class Fizzy::CLI::Help < Fizzy::CLI::Command
  def initialize
    super("Show how to use fizzy.")
  end

  def run
    url = URI.join(Fizzy::CFG.static_files_base_url, "BIGNAMI.md")
    res = Net::HTTP.get_response(url)
    if res.is_a?(Net::HTTPSuccess)
      tell("\n#{res.body}\n")
    else
      error("Network error: cannot retrieve `#{url}`.")
    end
  end
end
