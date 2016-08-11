module Fizzy::Sync

  class << self
    include Fizzy::IO
  end

  def self.available
    [ Fizzy::Sync::Git,
      Fizzy::Sync::Local
    ]
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

  attr_reader :name

  def initialize(name, local_dir_path, remote_url)
    error("Invalid local directory: can't be empty.") if local_dir_path.nil?
    error("Invalid synchronizer name.") if name.nil?
    @name = name
    @local_dir_path = local_dir_path
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
    default?
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
