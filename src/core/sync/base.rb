module Fizzy::Sync

  class << self
    include Fizzy::IO
  end

  def self.available
    [ Fizzy::Sync::Local,
      Fizzy::Sync::Git
    ]
  end

  def self.others(subject)
    subject = subject.class unless subject.is_a?(Class)
    result = available
    result.delete(subject)
    result
  end

  def self.enabled(local_dir_path, remote_url)
    available.map{|e| e.new(local_dir_path, remote_url)}.select{|e| e.enabled?}
  end

  def self.selected(local_dir_path, remote_url)
    enabled(local_dir_path, remote_url).first
  end

  def self.perform(local_dir_path, remote_url)
    synchronizer = selected(local_dir_path, remote_url)
    tell("Using synchronizer: `#{colorize(synchronizer.name, :magenta)}`", :cyan)

    status   = true
    status &&= synchronizer.update_remote if synchronizer.local_changed?
    status &&= synchronizer.update_local  if synchronizer.remote_changed?
    status
  end
end

class Fizzy::Sync::Base

  include Fizzy::IO

  attr_reader :name

  def initialize(synchronizer_name, local_dir_path, remote_url)
    must :synchronizer_name, be: :not_nil
    must :local_dir_path,    be: Pathname

    @name           = synchronizer_name
    @local_dir_path = local_dir_path
    @remote_url     = remote_url
  end

  # Check if the current synchronizer is enabled.
  #
  # Note: inheritors should call the `super` method.
  #
  # Example:
  #
  #   def enabled?
  #     my_policy || super
  #   end
  #
  def enabled?
    return false if !@remote_url.nil? &&
                    Fizzy::Sync.others(self).any? { |e|
                      @remote_url.start_with?("#{e.name}:")
                    }
    return true if default? && Fizzy::Sync.others(self).
      map  { |e| e.new(@local_dir_path, @remote_url) }.
      all? { |e| !e.enabled? }
  end

  # Check if the current synchronizer is the default synchronizer.
  #
  def default?
    self.class == Fizzy::Sync.available.last
  end

  # Update local from the remote.
  #
  abstract_method :update_local

  # Update remote from local.
  #
  abstract_method :update_remote

  # Check if local is changed, and now is different from latest remote state.
  #
  abstract_method :local_changed?

  # Check if remote is changed, and now is different from latest local state.
  #
  abstract_method :remote_changed?

end
