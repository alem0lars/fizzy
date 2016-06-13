class Fizzy::Sync::Local < Fizzy::Sync::Base

  def initialize(local_dir_path, remote_url)
    super
    @remote_path = Pathname.new(@remote_url)
  end

  # Check if the synchronizer is enabled.
  #
  def enabled?
    @remote_path.directory? || super
  end

  # Update local from the remote.
  #
  def update_local
    # TODO
  end

  # Update remote from local.
  #
  def update_remote
    # TODO
  end

  # Check if local is changed, and now is different from latest remote state.
  #
  def local_changed?
    # TODO
  end

  # Check if remote is changed, and now is different from latest local state.
  #
  def remote_changed?
    # TODO
  end

end
