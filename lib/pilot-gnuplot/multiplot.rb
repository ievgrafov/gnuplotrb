module Gnuplot
  class Multiplot
    include Plottable
    ##
    # Terminal object used by this Plot to pipe data to gnuplot.
    attr_reader :terminal
    ##
    # Array of datasets which are plotted by this object.
    attr_reader :plots

    def initialize(*plots, **options)
      @plots = plots[0].is_a?(Hamster::Vector) ? plots[0] : Hamster::Vector.new(plots)
      @options = Hamster.hash(options)
      @terminal = Terminal.new
      OptionHandling.validate_terminal_options(@options)
    end

    def new_with_options(options)
      self.class.new(@plots, options)
    end

    def mp_option?(key)
      %w(title layout).include?(key.to_s)
    end

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
