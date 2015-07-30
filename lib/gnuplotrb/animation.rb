module GnuplotRB
  ##
  # === Overview
  # Animation allows to create gif animation with given plots
  # as frames. Possible frames: Plot, Splot, Multiplot.
  # More about its usage in {animation notebook}[http://nbviewer.ipython.org/github/dilcom/gnuplotrb/blob/master/notebooks/animated_plots.ipynb].
  class Animation < Multiplot
    ##
    # *Plot* here is also named as *frame*
    alias_method :frames, :plots
    alias_method :update_frame, :update_plot
    alias_method :replace_frame, :replace_plot
    alias_method :add_frame, :add_plot
    alias_method :add_frames, :add_plots
    alias_method :remove_frame, :remove_plot

    ##
    # ====== Overview
    # This method creates a gif animation where frames are plots
    # already contained by Animation object.
    # ====== Arguments
    # * *term* - Terminal to plot to
    # * *options* - will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]', 'set title 'plot'' etc)
    # Options passed here have priority over already existing.
    # Inner options of Plots have the highest priority (except
    # :term and :output which are ignored).
    def plot(path = nil, **options)
      options[:output] ||= path
      plot_options = mix_options(options) do |plot_opts, anim_opts|
        plot_opts.merge(term: ['gif', anim_opts])
      end.to_h
      need_output = plot_options[:output].nil?
      plot_options[:output] = Dir::Tmpname.make_tmpname('anim', 0) if need_output
      terminal = Terminal.new
      multiplot(terminal, plot_options)
      # guaranteed wait for plotting to finish
      terminal.close
      if need_output
        result = File.binread(plot_options[:output])
        File.delete(plot_options[:output])
      else
        result = nil
      end
      result
    end

    ##
    # #to_<term_name> methods are not supported by animation
    def to_specific_term(*_)
      fail 'Specific terminals are not supported by Animation'
    end

    ##
    # This method is used to embed gif animations
    # into iRuby notebooks.
    def to_iruby
      gif_base64 = Base64.encode64(plot)
      ['text/html', "<img src=\"data:image/gif;base64, #{gif_base64}\">"]
    end

    private

    ##
    # Dafault options to be used for that plot
    def default_options
      {
        animate: {
          delay: 10,
          loop: 0,
          optimize: true
        }
      }
    end

    ##
    # This plot have some specific options which
    # should be handled different way than others.
    # Here are keys of this options.
    def specific_keys
      %w(
        animate
        size
        background
        transparent
        enhanced
        rounded
        butt
        linewidth
        dashlength
        tiny
        small
        medium
        large
        giant
        font
        fontscale
        crop
      )
    end
  end
end
