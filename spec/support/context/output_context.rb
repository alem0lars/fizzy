shared_context :output do

  # Redirect stderr and stout to a null-stream.
  #
  def silence_output
    # Store the original stderr and stdout in order to restore them later
    @original_stderr = $stderr
    @original_stdout = $stdout

    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end

  # Replace stderr and stdout so anything else is output correctly.
  #
  def enable_output
    $stderr = @original_stderr
    $stdout = @original_stdout
    @original_stderr = nil
    @original_stdout = nil
  end

end
