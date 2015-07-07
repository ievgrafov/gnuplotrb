module GnuplotRB
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

    def default_options
      {
        layout: [2,2],
        title: 'Multiplot'
      }
    end

    def specific_keys
      %w(
        title
        layout
      )
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
    def specific_option?(key)
      specific_keys.include?(key.to_s)
    end

    def mix_options(options)
      all_options = @options.merge(options)
      specific_options, plot_options = all_options.partition { |key, _value| specific_option?(key) }
      yield(plot_options, default_options.merge(specific_options))
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
      plot_options = mix_options(options) { |plot_opts, mp_opts| plot_opts.merge(multiplot: mp_opts.to_h) }
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

    ##
    # ====== Overview
    # Create new Multiplot object where plot (Plot or Splot object)
    # at *position* will
    # be replaced with the new one created from it by updating.
    # To update a plot you can pass some options for it or a
    # block, that should take existing plot (with new options if
    # you gave them) and return a plot too.
    # ====== Arguments
    # * *position* - position of plot which you need to update
    #   (by default first plot is updated)
    # * *options* - options to update plot with
    # * method also may take a block which returns a plot
    # ====== Example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   updated_mp = mp.update_plot(title: 'Sin(x) and Exp(x)') { |sinx| sinx.add_dataset('exp(x)') }
    def update_plot(position = 0, **options)
      return self unless block_given? if options.empty?
      replacement = @plots[position].options(options)
      replacement = yield(replacement) if block_given?
      replace_plot(position, replacement)
    end

    alias_method :update, :update_plot

    ##
    # ====== Overview
    # Create new Multiplot object where plot (Plot or Splot object)
    # at *position* will be replaced with the given one.
    # ====== Arguments
    # * *position* - position of plot which you need to update
    #   (by default first plot is updated)
    # * *plot* - replacement for existing plot
    # ====== Example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp_with_replaced_plot = mp.replace_plot(Plot.new('exp(x)', title: 'exp instead of sin'))
    def replace_plot(position = 0, plot)
      self.class.new(@plots.set(position, plot), @options)
    end

    alias_method :replace, :replace_plot

    ##
    # ====== Overview
    # Create new Multiplot with given *plot* added before plot at given *position*.
    # (by default it adds plot at the front).
    # ====== Arguments
    # * *position* - position before which you want to add a plot
    # * *plot* - plot you want to add
    # ====== Example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   enlarged_mp = mp.add_plot(Plot.new('exp(x)')).layout([3,1])
    def add_plot(position = 0, plot)
      self.class.new(@plots.insert(position, plot), @options)
    end

    alias_method :<<, :add_plot
    alias_method :add, :add_plot

    ##
    # ====== Overview
    # Create new Multiplot without plot at given position
    # (by default last plot is removed).
    # ====== Arguments
    # * *position* - position of plot you want to remove
    # ====== Example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp_with_only_cos = mp.remove_plot(0)
    def remove_plot(position = -1)
      self.class.new(@plots.delete_at(position), @options)
    end

    alias_method :remove, :remove_plot

    ##
    # ====== Overview
    # Equal to #plots[*args] 
    def [](*args)
      @plots[*args]
    end
  end
end
