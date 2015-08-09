module GnuplotRB
  ##
  # Terminal keeps open pipe to gnuplot process, cares about naming in-memory
  # datablocks (just indexing with sequential integers). All the output
  # to gnuplot handled by this class. Terminal also handles options passed
  # to gnuplot as 'set key value'.
  class Terminal
    include ErrorHandling

    # order is important for some options
    OPTION_ORDER = [:term, :output, :multiplot, :timefmt, :xrange]

    private_constant :OPTION_ORDER

    class << self
      ##
      # Close given gnuplot pipe
      # @param stream [IO] pipe to close
      def close_arg(stream)
        stream.puts
        stream.puts 'exit'
        Process.waitpid(stream.pid)
      end

      ##
      # Plot test page for given term_name into file
      # with file_name (optional).
      #
      # Test page contains possibilities of the term.
      # @param term_name [String] terminal name ('png', 'gif', 'svg' etc)
      # @param file_name [String] filename to output image if needed
      #   and chosen terminal supports image output
      # @return nil
      def test(term_name, file_name = nil)
        Terminal.new.set(term: term_name).test(file_name)
      end
    end

    ##
    # Create new Terminal connected with gnuplot.
    # Uses Settings::gnuplot_path to find gnuplot
    # executable. Each time you create Terminal it starts new
    # gnuplot subprocess which is closed after GC deletes
    # linked Terminal object.
    #
    # @param :persist [Boolean] gnuplot's "-persist" option
    def initialize(persist: false)
      @cmd = Settings.gnuplot_path
      @current_datablock = 0
      @cmd += ' -persist' if persist
      @cmd += ' 2>&1'
      stream = IO.popen(@cmd, 'w+')
      handle_stderr(stream)
      ObjectSpace.define_finalizer(self, proc { Terminal.close_arg(stream) })
      @in = stream
      yield(self) if block_given?
    end

    ##
    # Output datablock to this gnuplot terminal.
    #
    # @param data [String] data stored in datablock
    # @example
    #   data = "1 1\n2 4\n3 9"
    #   Terminal.new.store_datablock(data)
    #   #=> returns '$DATA1'
    #   #=> outputs to gnuplot:
    #   #=>   $DATA1 << EOD
    #   #=>   1 1
    #   #=>   2 4
    #   #=>   3 9
    #   #=>   EOD
    def store_datablock(data)
      name = "$DATA#{@current_datablock += 1}"
      stream_puts "#{name} << EOD"
      stream_puts data
      stream_puts 'EOD'
      name
    end

    ##
    # Convert given options to gnuplot format.
    #
    # For {opt1: val1, .. , optN: valN} it returns
    #   set opt1 val1
    #   ..
    #   set optN valN
    #
    # @param ptions [Hash] options to convert
    # @return [String] options in Gnuplot format
    def options_hash_to_string(options)
      result = ''
      options.sort_by { |key, _| OPTION_ORDER.find_index(key) || -1 }.each do |key, value|
        if value
          result += "set #{OptionHandling.option_to_string(key, value)}\n"
        else
          result += "unset #{key}\n"
        end
      end
      result
    end

    ##
    # Applie given options to current gnuplot instance.
    #
    # For {opt1: val1, .. , optN: valN} it will output to gnuplot
    #   set opt1 val1
    #   ..
    #   set optN valN
    #
    # @param options [Hash] options to set
    # @return [Terminal] self
    # @example
    #   set({term: ['qt', size: [100, 100]]})
    #   #=> outputs to gnuplot: "set term qt size 100,100\n"
    def set(options)
      OptionHandling.validate_terminal_options(options)
      stream_puts(options_hash_to_string(options))
    end

    ##
    # Unset options
    #
    # @param *options [Sequence of Symbol] each symbol considered as option key
    # @return [Terminal] self
    def unset(*options)
      options.flatten
             .sort_by { |key| OPTION_ORDER.find_index(key) || -1 }
             .each { |key| stream_puts "unset #{OptionHandling.string_key(key)}" }
      self
    end

    ##
    # Short way to plot Datablock, Plot or Splot object.
    # Other items will be just piped out to gnuplot.
    # @param item Object that should be outputted to Gnuplot
    # @return [Terminal] self
    def <<(item)
      if item.is_a? Plottable
        item.plot(self)
      else
        stream_print(item.to_s)
      end
      self
    end

    ##
    # Just put *command* + "\n" to gnuplot pipe.
    # @param command [String] command to send
    # @return [Terminal] self
    def stream_puts(command)
      stream_print("#{command}\n")
    end

    ##
    # Just print *command* to gnuplot pipe.
    # @param command [String] command to send
    # @return [Terminal] self
    def stream_print(command)
      check_errors
      @in.print(command)
      self
    end

    ##
    # @deprecated
    # Call replot on gnuplot. This will execute last plot once again
    # with rereading data.
    # @param options [Hash] options will be set before replotting
    # @return [Terminal] self
    def replot(**options)
      set(options)
      stream_puts('replot')
      unset(options.keys)
      sleep 0.01 until File.size?(options[:output]) if options[:output]
      self
    end

    ##
    # Send gnuplot command to turn it off and for its Process to quit.
    # Closes pipe so Terminal object should not be used after #close call.
    def close
      check_errors
      Terminal.close_arg(@in)
    end


    ##
    # Plot test page into file with file_name (optional).
    #
    # Test page contains possibilities of the term.
    # @param file_name [String] filename to output image if needed
    #   and chosen terminal supports image output
    # @return nil
    def test(file_name = nil)
      set(output: file_name) if file_name
      stream_puts('test')
      unset(:output)
      nil
    end
  end
end
