module Gnuplot
  ##
  # === Overview
  # Terminal keeps open pipe to gnuplot process, cares about naming datablocks and
  # linestyles (just indexing with sequncial integers). All the output to gnuplot
  # handled by this class. Terminal also handles options passed to gnuplot via
  # 'set key value'.
  class Terminal
    ##
    # ==== Parameters
    # * *persist* - gnuplot's -persist option
    def initialize(persist: false)
      @cmd = Settings::gnuplot_path
      @current_datablock = 0
      @cmd += ' -persist' if persist
      input = IO.popen(@cmd, 'w')
      ObjectSpace.define_finalizer(self, proc { input.close_write })
      @in = input
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Prints datablock to this gnuplot terminal
    # ==== Parameters
    # * *name* - passing this may be useful to update data before replot
    # * *data* - data stored in datablock
    def store_datablock(name = nil, data)
      name ||= "$DATA#{@current_datablock += 1}"
      @in.puts "#{name} << EOD"
      @in.puts data
      @in.puts 'EOD'
      name
    end

    ##
    # ==== Overview
    # Converts given options to gnuplot format;
    # for {opt1: val1, .. , optN: valN} it return
    #   set opt1 val1
    #   ..
    #   set optN valN
    # ==== Parameters
    # *options* - hash of options to convert
    def options_hash_to_string(options)
      result = ""
      options.each do |key, value|
        if value
          result += "set #{OptionsHelper::option_to_string(key, value)}\n"
        else
          result += "unset #{key}\n"
        end
      end
      result
    end

    ##
    # ==== Overview
    # Applies given options to current gnuplot instance;
    # for {opt1: val1, .. , optN: valN} it will output to gnuplot
    #   set opt1 val1
    #   ..
    #   set optN valN
    # ==== Parameters
    # *options* - hash of options to set
    # ==== Examples
    #   set({term: ['qt', size: [100, 100]]})
    def set(options)
      OptionsHelper::validate_terminal_options(options)
      @in.puts(options_hash_to_string(options))
      self
    end

    ##
    # ==== Overview
    # Unset some options
    # ==== Parameters
    # **options* - Array of options need to unset
    def unset(*options)
      options.flatten.each { |key| @in.puts "unset #{key}" }
      self
    end

    ##
    # ==== Overview
    # Short way to output datablock, plot etc.
    # The method is under construction.
    def <<(a)
      case a
      when Dataset
        Plot.new(a).plot(self)
      when Plot
        a.plot(self)
      else
        @in << a.to_s
      end
      self
    end

    ##
    # ==== Overview
    # Just puts a to gnuplot pipe
    def puts(a)
      @in.puts(a)
      self
    end

    ##
    # ==== Overview
    # Call replot on gnuplot. This will execute last plot once again
    # with rereading data.
    def replot(**options)
      set(options)
      @in.puts('replot')
      unset(options.keys)
      self
    end
  end
end
