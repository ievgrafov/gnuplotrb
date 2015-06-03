module Gnuplot
  # Some values of options should be quoted to be read by gnuplot
  # TODO update list with data from gnuplot documentation !!!
  QUOTED = %w(title output xlabel x2label ylabel y2label clabel cblabel zlabel)

  ##
  # === Overview
  # Terminal keeps open pipe to gnuplot process, cares about naming datablocks and
  # linestyles (just indexing with sequncial integers). All the output to gnuplot
  # handled by this class. Terminal also handles options passed to gnuplot via
  # 'set key value'.
  class Terminal
    ##
    # ==== Parameters
    # * *command* - may specify path to gnuplot executable if none exists
    # in $PATH (env variable)
    # * *options* - the only option in use now is :persist
    def initialize(command = 'gnuplot', **options)
      @cmd = 'gnuplot'
      @current_datablock = 0
      @current_style = 0
      command += ' -persist' if options[:persist]
      input = IO.popen(command, 'w')
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
    # Recursive function that converts Ruby options to gnuplot
    # ==== Parameters
    # *option* - an option that should be converted
    # ==== Examples
    #   ['png', size: [300, 300]] => 'png size 300,300'
    #   0..100 => '[0:100]'
    def option_to_string(option)
      return '' if !!option == option # check for boolean
      case option
      when Array
        option.map { |el| option_to_string(el) }.join(option[0].is_a?(Numeric) ? ',' : ' ')
      when Hash
        option.map { |pair| "#{pair[0]} #{option_to_string(pair[1])}" }.join(' ')
      when Range
        "[#{option.begin}:#{option.end}]"
      else
        option.to_s
      end
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
          if QUOTED.include?(key.to_s)
            result += "set #{key} '#{option_to_string(value)}'\n"
          else
            result += "set #{key} #{option_to_string(value)}\n"
          end
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
