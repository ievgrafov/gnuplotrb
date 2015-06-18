module Gnuplot
  ##
  # === Overview
  # Multiplot allows to place several plots on one layout.
  class Multiplot
    include Plottable
    ##
    # Array of plots contained by this object.
    attr_reader :plots

    ##
    # ====== Arguments
    # * *plots* are Plot or Splot objects which should be placed
    #   on this multiplot
    # * *options* will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]' for { xrange: 1..10 },
    #   "set title 'plot'" for { title: 'plot' } etc) just as in Plot.
    #   Special options of Multiplot are :layout and :title.
    def initialize(*plots, **options)
      @plots = plots[0].is_a?(Hamster::Vector) ? plots[0] : Hamster::Vector.new(plots)
      @options = Hamster.hash(options)
      @terminal = Terminal.new
      OptionHandling.validate_terminal_options(@options)
    end

    ##
    # Create new Multiplot object with the same set of plots and
    # given options.
    def new_with_options(options)
      self.class.new(@plots, options)
    end

    ##
    # Check if given options corresponds to multiplot.
    # Multiplot special options are :title and :layout.
    def mp_option?(key)
      %w(title layout).include?(key.to_s)
    end

    ##
    # ====== Overview
    # This outputs all the plots to term (if given) or to this
    # Multiplot's own terminal.
    # ====== Arguments
    # * *term* - Terminal to plot to
    # * *options* - will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]', 'set title 'plot'' etc)
    # Options passed here have priority over already existing.
    # Inner options of Plots have the highest priority (except
    # :term and :output which are ignored).
    def plot(term = nil, **options)
      all_options = @options.merge(options)
      mp_options, plot_options = all_options.partition { |key, _value| mp_option?(key) }
      plot_options = plot_options.merge(multiplot: mp_options.to_h)
      terminal = term || (plot_options[:output] ? Terminal.new : @terminal)
      terminal.set(plot_options)
      @plots.each { |graph| graph.plot(terminal, multiplot_part: true) }
      terminal.unset(plot_options.keys)
      if plot_options[:output]
        # guaranteed wait for plotting to finish
        terminal.close unless term
        # not guaranteed wait for plotting to finish
        # work bad with terminals like svg and html
        sleep 0.01 until File.size?(plot_options[:output])
      end
      self
    end
  end
end
