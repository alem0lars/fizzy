#
# Manage commands declared in the meta file.
#
module Fizzy::Meta::Commands

  #
  # Base command.
  #
  class Base
    include Fizzy::IO

    def type
      self.class.type
    end

    def invalid_spec(name, value = nil)
      msg  = "Invalid `#{name}` provided to command `#{type}`: "
      msg += value.nil? ? "no value given." : "`#{value}`."

      error msg
    end

    protected :invalid_spec
  end

  #
  # Meta-Command that syncs a repository.
  #
  # Spec:
  #
  # * `repo`: The repository specification.
  # * `dst`: The destination path.
  #
  class Sync < Base
    def validate!(spec)
      # 1: Validate.
      invalid_spec :repo unless spec.key? :repo
      invalid_spec :dst unless spec.key? :dst

      # 2: Normalize.
      @repo = spec[:repo]
      @dst  = Pathname.new(spec[:dst]).expand_variables.expand_path
    end

    def execute
      Fizzy::Sync.perform(@dst, @repo)
    end

    def self.type
      :sync
    end
  end

  #
  # Meta-Command that performs a file download.
  #
  # Spec:
  #
  # * `url`: The URL where the file should be downloaded.
  # * `dst`: The destination path.
  #
  class Download < Base
    def validate!(spec)
      # 1: Validate.
      invalid_spec :url unless spec.key? :url
      invalid_spec :dst unless spec.key? :dst

      # 2: Normalize.
      @url = URI(spec[:url])
      @dst = Pathname.new(spec[:dst]).expand_variables.expand_path
    end

    def execute
      res = Net::HTTP.get_response(@url)
      if res.is_a? Net::HTTPSuccess
        # TODO: atm it requires the current user has write access.
        #      refactor when a more robust permission mgmt is implemented.
        FileUtils.mkdir_p(@dst.dirname)
        @dst.write(res.body)
      else
        error "Network error: cannot retrieve #{✏ @url}."
      end
    end

    def self.type
      :download
    end
  end

  #
  # Get available meta-commands.
  #
  def self.available
    [Sync, Download]
  end

  #
  # Find the matching meta-command from given type.
  #
  def self.find_by_type(type)
    found = Fizzy::Meta::Commands.available.select do |command|
      command.type == type
    end

    if found.empty?
      error "Failed to find a command with type #{✏ type}."
    elsif found.length != 1
      error "[BUG] Multiple commands matched type #{✏ type}."
    else
      found[0]
    end
  end
end
