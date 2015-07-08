module GnuplotRB
  ##
  # === Overview
  # Multiplot allows to place several plots on one layout.
  class Animation < Multiplot
    def default_options
      {
        animate: {
          delay: 10,
          loop: 0,
          optimize: true
        }
      }
    end

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

    alias_method :frames, :plots
    alias_method :update_frame, :update_plot
    alias_method :replace_frame, :replace_plot
    alias_method :add_frame, :add_plot
    alias_method :add_frames, :add_plots
    alias_method :remove_frame, :remove_plot

    def plot(path = nil, **options)
      options[:output] ||= path
      plot_options = mix_options(options) do |plot_opts, anim_opts|
        plot_opts.merge(term: ['gif', anim_opts])
      end
      need_output = plot_options[:output].nil?
      plot_options[:output] = Dir::Tmpname.make_tmpname('anim', 0) if need_output
      terminal = Terminal.new
      multiplot(terminal, plot_options)
      # guaranteed wait for plotting to finish
      terminal.close
      # not guaranteed wait for plotting to finish
      # work bad with terminals like svg and html
      sleep 0.01 until File.size?(plot_options[:output])
      if need_output
        result = File.binread(plot_options[:output])
        File.delete(plot_options[:output])
      else
        result = nil
      end
      result
    end

    def to_specific_term(*args)
      fail RuntimeError, 'Specific terminals are not supported by Animation'
    end
  end
end
