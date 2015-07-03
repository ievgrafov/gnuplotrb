module GnuplotRB
  ##
  # This module contains methods that should be mixed into
  # plottable classes. It includes OptionHandling and
  # implements several plotting methods.
  module Plottable
    include OptionHandling

    ##
    # Terminal object used by this Plottable to pipe data to gnuplot.
    attr_reader :terminal

    ##
    # You should implement #plot in classes that are Plottable
    def plot(*args)
      fail NotImplementedError, 'You should implement #plot in classes that are Plottable!'
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
    #   ## plot here may be Plot, Splot, Multiplot or any other plottable class
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
    #   plot = Splot.new
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
    #   multiplot.to_png('./result.png', size: [300, 500], font: ['arial', 12])
    #   # font options specific for svg term
    #   content = multiplot.to_svg(size: [100, 100], fname: 'Arial', fsize: 12)
    def method_missing(meth_id, *args)
      meth = meth_id.id2name
      if meth[0..2] == 'to_'
        term = meth[3..-1]
        super unless OptionHandling.valid_terminal?(term)
        to_specific_term(term, *args)
      else
        option(meth_id, *args)
      end
    end

    ##
    # Returns true foe existing methods and
    # #to_<term_name> when name is a valid terminal type.
    def respond_to?(meth_id)
      # Next line is here to force iRuby use #to_iruby
      # instead of #to_svg.
      return super if defined? IRuby
      meth = meth_id.id2name
      term = meth[0..2] == 'to_' && OptionHandling.valid_terminal?(meth[3..-1])
      term || super
    end
  end
end
