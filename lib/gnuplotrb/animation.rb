module GnuplotRB
  ##
  # === Overview
  # Multiplot allows to place several plots on one layout.
  class Animation < Multiplot
    ANIMATION_DELAY = 10

    alias_method :frames, :plots
    alias_method :update_frame, :update_plot
    alias_method :replace_frame, :replace_plot
    alias_method :add_frame, :add_plot
    alias_method :remove_frame, :remove_plot

    def initialize(*plots, **options)
      super
    end

    def invalid_gif_term?(gif_term)
      term_name = gif_term.is_a?(Array) ? gif_term[0] : gif_term
      term_name != 'gif'
    end

    def plot(path = nil, **options)
      plot_options = @options.merge(options).to_h
      plot_options[:output] ||= path
      need_output = plot_options[:output].nil?
      need_term = plot_options[:term].nil? || invalid_gif_term(plot_options[:term])
      plot_options[:term] = ['gif', delay: ANIMATION_DELAY, animate: true, optimize: true] if need_term
      plot_options[:output] = Dir::Tmpname.make_tmpname('anim', 0) if need_output
      terminal = Terminal.new
      terminal.set(plot_options)
      @plots.each { |graph| graph.plot(terminal, multiplot_part: true) }
      terminal.unset(plot_options.keys)
      # guaranteed wait for plotting to finish
      terminal.close
      # not guaranteed wait for plotting to finish
      # work bad with terminals like svg and html
      sleep 0.01 until File.size?(plot_options[:output])
      if need_output
        result = File.binread(plot_options[:output])
        File.delete(plot_options[:output])
      else
        result = self
      end
      result
    end

    def to_specific_term(*args)
      fail RuntimeError, 'Specific terminals are supported by Animation'
    end
  end
end
