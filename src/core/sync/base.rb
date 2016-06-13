module Fizzy::Sync

  def self.available
    [ Fizzy::Sync::Local,
      Fizzy::Sync::Git
    ]
  end

  def self.enabled(local_dir_path, remote_url)
    available.map{|e| e.new(local_dir_path, remote_url)}.select{|e| e.enabled?}
  end

  def self.selected(local_dir_path, remote_url)
    enabled(local_dir_path, remote_url).first
  end

  def self.perform(local_dir_path, remote_url)
    synchronizer = selected_synchronizer(local_dir_path, remote_url)

    status   = true
    status ||= synchronizer.update_remote if synchronizer.local_changed?
    status ||= synchronizer.update_local  if synchronizer.remote_changed?
  end
end

class Fizzy::Sync::Base

  def initialize(local_dir_path, remote_url)
    error("Invalid local directory: can't be empty.") if local_dir_path.nil?
    error("Invalid url: can't be empty.")             if remote_url.nil?
    @local_dir_path = local_dir_path
    @remote_url     = remote_url
  end

  # Check if the synchronizer is enabled.
  #
  def enabled?
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
