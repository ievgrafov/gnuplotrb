module GnuplotRB
  ##
  # Just a new error name
  class GnuplotError < ArgumentError
  end

  ##
  # Mixin for classes that need to run subprocess and
  # handle errors from its stderr.
  module ErrorHandling
    ##
    # ====== Overview
    # Check if there were errors in previous commands.
    # Throws GnuplotError in case of any errors.
    def check_errors
      unless @err_array.empty?
        command = @err_array.first
        rest = @err_array[1..-1].join('; ')
        message = "Error in previous command (\"#{command}\"): \"#{rest}\""
        @err_array.clear
        fail GnuplotError, message
      end
    end

    ##
    # ====== Overview
    # Start new thread that will read stderr given as stream
    # and add errors into @err_array.
    def handle_stderr(stream)
      @err_array = []
      Thread.new do
        until (line = stream.gets).nil? do
          line.strip!
          @err_array << line if line.size > 3
        end
      end
    end

    private :check_errors,
            :handle_stderr
  end
end
