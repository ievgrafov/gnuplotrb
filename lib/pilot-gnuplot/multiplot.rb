module Gnuplot
  class Multiplot
    ##
    # Terminal object used by this Plot to pipe data to gnuplot.
    attr_reader :terminal
    ##
    # Array of datasets which are plotted by this object.
    attr_reader :plots

    def initialize(*plots, **options)
      @plots = Hamster::Vector.new(plots)
      @options = Hamster.hash(options)
      @terminal = Terminal.new
      OptionsHelper.validate_terminal_options(@options)
    end

    def mp_option?(key)
      %w(title layout).include?(key.to_s)
    end

    def plot(term = nil, **options)
      all_options = @options.merge(options).to_h
      mp_options = all_options.select { |key| mp_option?(key) }
      plot_options = all_options.reject { |key| mp_option?(key) }
      puts mp_options[:layout]
      terminal = term || (plot_options[:output] ? Terminal.new : @terminal)
      terminal.set(**plot_options, multiplot: mp_options)
      @plots.each { |graph| graph.plot(terminal, multiplot_part: true) }
      terminal.unset(:multiplot, *plot_options.keys)
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
    # Method for inner use.
    # ====== Overview
    # Method which outputs plot to specific terminal (possibly some file).
    # Explicit use should be avoided. This method is called from #method_missing
    # when it handles method names like #to_png(options).
    # ====== Arguments
    # * *terminal* - string corresponding to terminal type (png, html, jpeg etc)
    # * *path* - path to output file, if none given it will output to temp file
    #   and then read it and return binary contents of file
    # * *options* - used in 'set term <term type> <options here>'
    # ====== Examples
    #   plot.to_png('./result.png', size: [300, 500])
    #   contents = plot.to_svg(size: [100, 100])
    #   plot.to_dumb('./result.txt', size: [30, 15])
    def to_specific_term(terminal, path = nil, **options)
      if path
        result = plot(term: [terminal, options], output: path)
      else
        path = Dir::Tmpname.make_tmpname(terminal, 0)
        plot(term: [terminal, options], output: path)
        result = File.binread(path)
        File.delete(path)
      end
      result
    end

    ##
    # ====== Overview
    # In this gem #method_missing is used both to handle
    # options and to handle plotting to specific terminal.
    #
    # ====== Options handling
    # ======= Overview
    # You may set options using #option_name(option_value) method.
    # A new object will be constructed with selected option set.
    # And finally you can get current value of any option using
    # #options_name without arguments.
    # ======= Arguments
    # * *option_value* - value to set an option. If none given
    #   method will just return current option's value
    # ======= Examples
    #   plot = Plot.new
    #   new_plot = plot.title('Awesome plot')
    #   plot.title #=> nil
    #   new_plot.title #=> 'Awesome plot'
    #
    # ====== Plotting to specific term
    # ======= Overview
    # Gnuplot offers possibility to output graphics to many image formats.
    # The easiest way to to so is to use #to_<plot_name> methods.
    # ======= Arguments
    # * *options* - set of options related to terminal (size, font etc).
    #   Be careful, some terminals have their own specific options.
    # ======= Examples
    #   # font options specific for png term
    #   plot.to_png('./result.png', size: [300, 500], font: ['arial', 12])
    #   # font options specific for svg term
    #   content = plot.to_svg(size: [100, 100], fname: 'Arial', fsize: 12)
    def method_missing(meth_id, *args)
      meth = meth_id.id2name
      if meth[0..2] == 'to_'
        term = meth[3..-1]
        super unless OptionsHelper.valid_terminal?(term)
        to_specific_term(term, *args)
      else
        if args.empty?
          value = @options[meth.to_sym]
          value = value[0] if value && value.size == 1
          value
        else
          options(meth.to_sym => args)
        end
      end
    end

    ##
    # Checks only for valid term.
    def respond_to?(meth_id)
      meth = meth_id.id2name
      !(meth[0..2] == 'to_') || OptionsHelper.valid_terminal?(meth[3..-1])
    end
  end
end

=begin
require 'pilot-gnuplot'
include Gnuplot
plots = [Plot.new('sin(x)'), Plot.new('cos(x)')]
mp = Multiplot.new(*plots, layout: [2,1])
=end