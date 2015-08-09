module GnuplotRB
  ##
  # Multiplot allows to place several plots on one layout.
  # It's usage is covered in
  # {multiplot notebook}[http://nbviewer.ipython.org/github/dilcom/gnuplotrb/blob/master/notebooks/multiplot_layout.ipynb].
  #
  # == Options
  # Most of Multiplot options are the same as in Plot so one can also set any options related
  # to Plot and they will be considered by all nested plots
  # (if they does not override it with their own values).
  #
  # There are only 2 specific options:
  # * title - set title for the whole layout (above all the plots)
  # * layout - set layout size, examples:
  #     { layout : [1, 3] } # 3 plots, 1 row, 3 columns
  #     { layout : [2, 2] } # 4 plots, 2 rows, 2 columns
  class Multiplot
    include Plottable
    ##
    # @return [Array] Array of plots contained by this object
    attr_reader :plots

    ##
    # @param plots [Plot, Splot, Hamster::Vector] Hamster vector (or just sequence) with Plot
    #   or Splot objects which should be placed on this multiplot layout
    # @param options [Hash] see options in top class docs
    def initialize(*plots, **options)
      @plots = plots[0].is_a?(Hamster::Vector) ? plots[0] : Hamster::Vector.new(plots)
      @options = Hamster.hash(options)
      OptionHandling.validate_terminal_options(@options)
      yield(self) if block_given?
    end

    ##
    # Output all the plots to term (if given) or to this Multiplot's own terminal.
    #
    # @param term [Terminal] Terminal to plot to
    # @param multiplot_part [Boolean] placeholder, does not really needed and should not be used
    # @param options [Hash] see options in top class docs.
    #   Options passed here have priority over already set.
    # @return [Multiplot] self
    def plot(term = nil, multiplot_part: false, **options)
      plot_options = mix_options(options) do |plot_opts, mp_opts|
        plot_opts.merge(multiplot: mp_opts.to_h)
      end
      terminal = term || (plot_options[:output] ? Terminal.new : own_terminal)
      multiplot(terminal, plot_options)
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
    # Create new updated Multiplot object
    # where plot (Plot or Splot object) at *position* will
    # be replaced with the new one created from it by updating.
    # To update a plot you can pass some options for it or a
    # block, that should take existing plot (with new options if
    # you gave them) and return a plot too.
    #
    # Method yields new created Plot or Splot to allow you update it manually.
    #
    # @param position [Integer] position of plot which you need to update
    #   (by default first plot is updated)
    # @param options [Hash] options to set into updated plot
    # @return [Multiplot] self
    # @yieldparam plot [Plot, Splot] a new plot
    # @yieldreturn [Plot, Splot] changed plot
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   updated_mp = mp.update_plot(title: 'Sin(x) and Exp(x)') { |sinx| sinx.add!('exp(x)') }
    #   # mp IS NOT affected
    def update_plot(position = 0, **options)
      return self unless block_given? if options.empty?
      replacement = @plots[position].options(options)
      replacement = yield(replacement) if block_given?
      replace_plot(position, replacement)
    end

    alias_method :update, :update_plot

    ##
    # Destructive version of #update_plot.
    #
    # @return [Multiplot] self
    # @example
    #   Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp.update_plot!(title: 'Sin(x) and Exp(x)') { |sinx| sinx.add!('exp(x)') }
    #   # mp IS affected
    def update_plot!(position = 0, **options)
      return self unless block_given? if options.empty?
      replacement = @plots[position].options!(options)
      yield(replacement) if block_given?
      self
    end

    alias_method :update!, :update_plot!

    ##
    # Create new Multiplot object where plot (Plot or Splot object)
    # at *position* will be replaced with the given one.
    #
    # @param position [Integer] position of plot which you need to replace
    #   (by default first plot is replace)
    # @param plot [Plot, Splot] replacement
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp_with_replaced_plot = mp.replace_plot(Plot.new('exp(x)', title: 'exp instead of sin'))
    #   # mp IS NOT affected
    def replace_plot(position = 0, plot)
      self.class.new(@plots.set(position, plot), @options)
    end

    alias_method :replace, :replace_plot

    ##
    # Destructive version of #replace_plot.
    #
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp.replace_plot!(Plot.new('exp(x)', title: 'exp instead of sin'))
    #   # mp IS affected
    def replace_plot!(position = 0, plot)
      @plots = @plots.set(position, plot)
      self
    end

    alias_method :replace!, :replace_plot!
    alias_method :[]=, :replace_plot!

    ##
    # Create new Multiplot with given *plots* added before plot at given *position*.
    # (by default it adds plot at the front).
    #
    # @param position [Integer] position of plot which you need to replace
    #   (by default first plot is replace)
    # @param plots [Sequence of Plot or Splot] plots you want to add
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   enlarged_mp = mp.add_plots(Plot.new('exp(x)')).layout([3,1])
    #   # mp IS NOT affected
    def add_plots(*plots)
      plots.unshift(0) unless plots[0].is_a?(Numeric)
      self.class.new(@plots.insert(*plots), @options)
    end

    alias_method :add_plot, :add_plots
    alias_method :<<, :add_plots
    alias_method :add, :add_plots

    ##
    # Destructive version of #add_plots.
    #
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp.add_plots!(Plot.new('exp(x)')).layout([3,1])
    #   # mp IS affected
    def add_plots!(*plots)
      plots.unshift(0) unless plots[0].is_a?(Numeric)
      @plots = @plots.insert(*plots)
      self
    end

    alias_method :add_plot!, :add_plots!
    alias_method :add!, :add_plots!

    ##
    # Create new Multiplot without plot at given position
    # (by default last plot is removed).
    #
    # @param position [Integer] position of plot which you need to remove
    #   (by default last plot is removed)
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp_with_only_cos = mp.remove_plot(0)
    #   # mp IS NOT affected
    def remove_plot(position = -1)
      self.class.new(@plots.delete_at(position), @options)
    end

    alias_method :remove, :remove_plot

    ##
    # Destructive version of #remove_plot.
    #
    # @return [Multiplot] self
    # @example
    #   mp = Multiplot.new(Plot.new('sin(x)'), Plot.new('cos(x)'), layout: [2,1])
    #   mp.remove_plot!(0)
    #   # mp IS affected
    def remove_plot!(position = -1)
      @plots = @plots.delete_at(position)
      self
    end

    alias_method :remove!, :remove_plot!

    ##
    # Equal to #plots[*args]
    def [](*args)
      @plots[*args]
    end

    private

    ##
    # Default options to be used for that plot
    def default_options
      {
        layout: [2, 2],
        title: 'Multiplot'
      }
    end

    ##
    # This plot have some specific options which
    # should be handled different way than others.
    # Here are keys of this options.
    def specific_keys
      %w(
        title
        layout
      )
    end

    ##
    # Create new Multiplot object with the same set of plots and
    # given options.
    # Used in OptionHandling module.
    def new_with_options(options)
      self.class.new(@plots, options)
    end

    ##
    # Check if given options corresponds to multiplot.
    # Uses #specific_keys to check.
    def specific_option?(key)
      specific_keys.include?(key.to_s)
    end

    ##
    # Takes all options and splits them into specific and
    # others. Requires a block where this two classes should
    # be mixed.
    def mix_options(options)
      all_options = @options.merge(options)
      specific_options, plot_options = all_options.partition { |key, _value| specific_option?(key) }
      yield(plot_options, default_options.merge(specific_options))
    end

    ##
    # Just a part of #plot.
    def multiplot(terminal, options)
      terminal.set(options)
      @plots.each { |graph| graph.plot(terminal, multiplot_part: true) }
      terminal.unset(options.keys)
    end
  end
end
