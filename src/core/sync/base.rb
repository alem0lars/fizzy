module Fizzy::Sync

  def self.available_synchronizers(local_dir_path, remote_url)
    [ Fizzy::Sync::Git,
      Fizzy::Sync::Local
    ].map{|s| s.new(local_dir_path, remote_url)}
  end

  def self.enabled_synchronizers(local_dir_path, remote_url)
    available_synchronizers(local_dir_path, remote_url).select{|s| s.enabled?}
  end

  def self.selected_synchronizer(local_dir_path, remote_url)
    enabled_synchronizers(local_dir_path, remote_url).first
  end

  def self.perform(local_dir_path, remote_url)
    synchronizer = selected_synchronizer(local_dir_path, remote_url)

    status   = true
    status ||= synchronizer.update_remote if synchronizer.local_changed?
    status ||= synchronizer.update_local  if synchronizer.remote_changed?
  end
end

class Fizzy::Sync::Base

  def initialize(local_dir, remote_url)
    error("Invalid url: can't be empty.")             if remote_url.nil?
    error("Invalid local directory: can't be empty.") if local_dir.nil?
    @remote_url = remote_url
    @local_dir  = local_dir
  end

  # Check if the synchronizer is enabled.
  #
  abstract_method :enabled?

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
