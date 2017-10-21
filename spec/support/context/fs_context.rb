shared_context :fs do
  #
  # Create a directory tree based on description given by `hash` starting from
  # base directory pointed by `base_dir_path`.
  #
  def mktree(hash, base_dir_path)
    hash.each do |key, value|
      key = key.to_s
      current_path = base_dir_path.join(key)
      if value.is_a? Hash
        current_path.mkpath
        mktree(value, current_path)
      else
        current_path.write(value)
      end
    end
  end
end
