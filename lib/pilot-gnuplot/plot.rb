module Gnuplot
  ##
  # === Overview
  # Plot correspond to simple 2d visualisation
  class Plot
    ##
    # ==== Parameters
    # * *datasets* are either instances of Dataset class or [data, **dataset_options] arrays
    # * *options* will be considered as 'settable' options of gnuplot ('set xrange [1:10]' for { xrange: 1..10 }, "set title 'plot'" for { title: 'plot' } etc)
    def initialize(*datasets, **options)
      @datasets = datasets.map{ |dataset| dataset.is_a?(Dataset) ? dataset : Dataset.new(*dataset) }
      @options = options
      @cmd = 'plot '
      @terminal = nil
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # This outputs plot to term (if given) or to last used term (if any)
    # or just builds its own Terminal with plot and options
    # ==== Parameters
    # * *term* - Terminal to plot to
    # * *options* - will be considered as 'settable' options of gnuplot ('set xrange [1:10]', 'set title 'plot'' etc);
    # options passed here have priority above already given to ::new
    def plot(term = nil, **options)
      term ||= (@terminal ||= Terminal.new)
      opts = @options.merge(options)
      term.set(opts)
      term.puts(@cmd + @datasets.map{ |dataset| dataset.to_s(term) }.join(' , '))
      term.unset(opts.keys)
    end

    ##
    # ==== Overview
    # Method which outputs plot to specific terminal (possibly some file).
    # Explicit use should be avoided. This method is called from #method_missing
    # when it handles method names like #to_png(options).
    # ==== Parameters
    # * *terminal* - string corresponding to terminal type (png, html, jpeg etc)
    # * *path* - path to output file, if none given it will output to temp file
    # and then read it and return binary data with contents of file
    # * *options* - used in 'set term <term type> <options here>'
    # ==== Examples
    #   plot.to_png(size: [300, 500])
    #   plot.to_svg(size: [100, 100])
    #   plot.to_dumb(size: [30, 15])
    def to_specific_term(terminal, path = nil, **options)
      if path
        result = self.plot(Terminal.new, term: [terminal, options], output: path)
      else
        path = Dir::Tmpname.make_tmpname(terminal, 0)
        plot(Terminal.new, term: [terminal, options], output: path)
        sleep(0.1) until File.exist?(path)
        result = File.binread(path)
        File.delete(path)
      end
      result
    end

    ##
    # ==== Overview
    # In this gem #method_missing is used both to handle
    # options and to handle plotting to specific terminal.
    #
    # ==== Options handling
    # ===== Overview
    # You may set options using #option_name(option_value) method.
    # A new object will be constructed with selected option set.
    # You may also change existing object instead of creating a new one:
    # #options_name!(option_value) will do so.
    # And finally you can get current value of any option using
    # #options_name without arguments.
    # ===== Examples
    #   new_plot = plot.title('Awesome plot')
    #   plot.title # >nil
    #   new_plot.title # >'Awesome plot'
    #   plot.title!('One more awesome plot')
    #   plot.title # >'One more awesome plot'
    #
    # ==== Plotting to specific term
    # ===== Overview
    # Gnuplot offers possibility to output graphics to many image formats.
    # The easiest way to to so is to use #to_<plot_name> methods.
    # ===== Parameters
    # * *options* - set of options related to terminal (size, font etc).
    # ===== Examples
    #   plot.to_png(size: [300, 500], font: ['arial', 12]) # options are specific for png term
    #   plot.to_svg(size: [100, 100], fname: 'Arial', fsize: 12) # options are specific for svg term
    #   plot.to_dumb(size: [30, 15])
    def method_missing(meth_id, *args)
      meth = meth_id.id2name
      if meth[0..2] == 'to_'
        to_specific_term(meth[3..-1], *args)
        return self
      end
      if args.empty?
        value = @options[meth.to_sym]
        value = value[0] if value && value.size == 1
        return value
      end
      case meth[-1, 1]
        when '!' then
          @options[meth[0..-2].to_sym] = args
        when '=' then
          super
        else
          Plot.new(*@datasets, @options.merge(meth.to_sym => args))
      end
    end
  end
end