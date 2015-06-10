module Gnuplot
  module OptionsHelper
    # Some values of options should be quoted to be read by gnuplot
    # TODO: update list with data from gnuplot documentation !!!
    QUOTED_OPTIONS = %w(title output xlabel x2label ylabel y2label clabel cblabel zlabel rgb)

    ##
    # ==== Overview
    # Recursive function that converts Ruby options to gnuplot
    # ==== Parameters
    # *option* - an option that should be converted
    # ==== Examples
    #   ['png', size: [300, 300]] => 'png size 300,300'
    #   0..100 => '[0:100]'
    def self.option_to_string(key = nil, option)
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
    # ==== Overview
    # Check if given terminal available for use.
    # ==== Arguments
    # * *terminal* - terminal to check (e.g. 'png', 'qt', 'gif')
    def self.valid_terminal?(terminal)
      Settings.available_terminals.include?(terminal)
    end

    ##
    # ==== Overview
    # Check if given options are valid for gnuplot.
    # Raises ArgumentError if invalid options found.
    # ==== Arguments
    # * *options* - Hash of options to check
    # (e.g. {term: 'qt', title: 'Plot title'})
    #
    # Now checks only terminal name.
    def self.validate_terminal_options(options)
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
end
