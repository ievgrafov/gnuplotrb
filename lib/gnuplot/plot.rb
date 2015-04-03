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
      # resetting is a bad way, will interfere multiplot
      # think about its importance
      @last_terminal.reset_options
      @last_terminal.set(@options.merge(options))
      @last_terminal.puts(@cmd + @datasets.map{ |dataset| dataset.to_s(@last_terminal) }.join(' , '))
    end

    ##
    # ==== Overview
    # Example of method which outputs plot to specific terminal (possibly some file)
    # ==== Parameters
    # * *path* - path to output file, if none given it will output to temp file
    # and then read it and return binary data with contents of file
    # * *options* - used in 'set term png <options here>'
    # ==== Example
    # #to_png(size: [300, 500])
    def to_png(path = nil, *options)
      if path
        result = self.plot(Terminal.new, term: ['png', options], output: path)
      else
        path = Dir::Tmpname.make_tmpname('png', 0)
        plot(Terminal.new, term: ['png', options], output: path)
        sleep(0.1) until File.exist?(path)
        puts path
        result = File.binread(path)
      end
      result
    end
  end
end