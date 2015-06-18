module Gnuplot
  ##
  # ====== Overview
  # This module contains methods which are mixed into several classes
  # to set, get and convert their options.
  module OptionHandling
    class << self
      # Some values of options should be quoted to be read by gnuplot
      #
      # TODO: update list with data from gnuplot documentation !!!
      QUOTED_OPTIONS = %w(title output xlabel x2label ylabel y2label clabel cblabel zlabel rgb)

      ##
      # ====== Overview
      # Recursive function that converts Ruby option to gnuplot string
      # ====== Arguments
      # * *key* - name of option in gnuplot
      # * *option* - an option that should be converted
      # ====== Examples
      #   option_to_string(['png', size: [300, 300]]) #=> 'png size 300,300'
      #   option_to_string(xrange: 0..100) #=> 'xrange [0:100]'
      #   option_to_string(multiplot: true) #=> 'multiplot'
      def option_to_string(key = nil, option)
        return key.to_s if !!option == option # check for boolean
        value = case option
                when Array
                  option.map { |el| option_to_string(el) }
                        .join(option[0].is_a?(Numeric) ? ',' : ' ')
                when Hash
                  option.map { |i_key, i_val| option_to_string(i_key, i_val) }
                        .join(' ')
                when Range
                  "[#{option.begin}:#{option.end}]"
                else
                  option.to_s
                end
        value = "'#{value}'" if QUOTED_OPTIONS.include?(key.to_s)
        value = "#{key} " + value if key
        value
      end

      ##
      # ====== Overview
      # Check if given terminal available for use.
      # ====== Arguments
      # * *terminal* - terminal to check (e.g. 'png', 'qt', 'gif')
      def valid_terminal?(terminal)
        Settings.available_terminals.include?(terminal)
      end

      ##
      # ====== Overview
      # Check if given options are valid for gnuplot.
      # Raises ArgumentError if invalid options found.
      # ====== Arguments
      # * *options* - Hash of options to check
      #   (e.g. {term: 'qt', title: 'Plot title'})
      #
      # Now checks only terminal name.
      def validate_terminal_options(options)
        terminal = options[:term]
        if terminal
          terminal = terminal[0] if terminal.is_a?(Array)
          message = 'Seems like your Gnuplot does not ' \
                    'support that terminal, please see supported ' \
                    'terminals with Terminal#available_terminals'
          fail(ArgumentError, message) unless valid_terminal?(terminal)
        end
      end
    end

    ##
    # You should implement #initialize in classes that use OptionsHelper
    def initialize(*args)
      fail NotImplementedError, 'You should implement #initialize in classes that use OptionsHelper!'
    end

    ##
    # You should implement #new_with_options in classes that use OptionsHelper
    def new_with_options(*args)
      fail NotImplementedError, 'You should implement #new_with_options in classes that use OptionsHelper!'
    end

    ##
    # ====== Overview
    # Create new Plot (or Dataset or Splot or Multiplot) object where current
    # options are merged with given. If no options
    # given it will just return existing set of options.
    # ====== Arguments
    # * *options* - options to add. If no options given, current
    #   options are returned.
    # ====== Example
    #   sin_graph = Plot.new(['sin(x)', title: 'Sin'], title: 'Sin on [0:3]', xrange: 0..3)
    #   sin_graph.plot
    #   sin_graph_update = sin_graph.options(title: 'Sin on [-10:10]', xrange: -10..10)
    #   sin_graph_update.plot
    #   # this may also be considered as
    #   # sin_graph.title(...).xrange(...)
    def options(**options)
      @options ||= Hamster::Hash.new
      if options.empty?
        @options
      else
        new_with_options(@options.merge(options))
      end
    end

    ##
    # Method for inner use.
    # ====== Arguments
    # * *key* - [Symbol] - option key
    # * *value* - anything treated as options value in gnuplot gem
    def option(key, *value)
      if value.empty?
        value = options[key]
        value = value[0] if value && value.size == 1
        value
      else
        options(key => value)
      end
    end

    private :option
  end
end
