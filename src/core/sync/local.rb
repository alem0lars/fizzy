class Fizzy::Sync::Local < Fizzy::Sync::Base

  def initialize(local_dir_path, remote_url)
    super(:local, local_dir_path, remote_url)
    @remote_path = @remote_url.nil? ? nil : Pathname.new(@remote_url)
  end

  # Check if the synchronizer is enabled.
  #
  def enabled?
      ( super ||
        !@remote_path.nil? && @remote_path.directory? ||
        local_valid_repo?)
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

  # Check if the local directory holds a valid local repository.
  #
  def local_valid_repo?
    @local_dir_path.directory?
  end

end
