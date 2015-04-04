module Gnuplot
  ##
  # === Overview
  # Plot correspond to simple 2d visualisation
  class Plot
    ##
    # ==== Parameters
    # * *datasets* are either instances of Dataset class or [data, **dataset_options] arrays
    # * *options* will be considered as 'settable' options of gnuplot ('set xrange [1:10]', 'set title 'plot'' etc)
    def initialize(*datasets, **options)
      @datasets = datasets.map{ |dataset| dataset.is_a?(Dataset) ? dataset : Dataset.new(*dataset) }
      @options = options
      @cmd = 'plot '
      @last_terminal = nil
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
      @last_terminal = term || @last_terminal || Terminal.new
      opts = @options.merge(options)
      @last_terminal.set(opts)
      @last_terminal.puts(@cmd + @datasets.map{ |dataset| dataset.to_s(@last_terminal) }.join(' , '))
      @last_terminal.unset(opts.keys)
    end

    ##
    # ==== Overview
    # Method which outputs plot to specific terminal (possibly some file)
    # ==== Parameters
    # * *terminal* - string corresponding to terminal type (png, html, jpeg etc)
    # * *path* - path to output file, if none given it will output to temp file
    # and then read it and return binary data with contents of file
    # * *options* - used in 'set term <term type> <options here>'
    # ==== Example
    # plot.to_png(size: [300, 500])
    # plot.to_svg(size: [100, 100])
    # plot.to_dumb(size: [30, 15])
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
    # Used for handling methods like #to_<term>. Possibly
    # will be used to handle calls like
    #   plot.option_name = value
    #   plot.option_name(value)
    #   value = plot.option_name
    def method_missing(meth_id, *args)
      meth = meth_id.id2name
      if meth[0..2] == 'to_'
        to_specific_term(meth[3..-1], *args)
      end
    end
  end
end