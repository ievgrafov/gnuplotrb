module Gnuplot
  class Multiplot
    MULTIPLOT_OPTIONS = %w(title layout)

    def initialize(*plots, **options)
      @plots = plots
      @options = options
      @term = Terminal.new
    end

    def mp_option?(key)
      MULTIPLOT_OPTIONS.include?(key.to_s)
    end

    def plot(terminal = @term, **options)
      all_options = @options.merge(options)
      mp_options = all_options.select { |key| mp_option?(key) }
      plot_options = all_options.reject { |key| mp_option?(key) } 
      terminal.set(**plot_options, multiplot: mp_options)
      @plots.each { |graph| graph.plot(terminal, multiplot_part: true) }
      terminal.unset(:multiplot, *plot_options.keys)
    end
  end
end
