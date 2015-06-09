require 'tempfile'
require 'hamster'
require 'open3'

require 'pilot-gnuplot/version'
require 'pilot-gnuplot/terminal'
require 'pilot-gnuplot/datablock'
require 'pilot-gnuplot/dataset'
require 'pilot-gnuplot/plot'
require 'pilot-gnuplot/splot'
require 'pilot-gnuplot/mixins'

##
# === Overview
# Ruby bindings for gnuplot.
module Gnuplot
  # Some values of options should be quoted to be read by gnuplot
  # TODO update list with data from gnuplot documentation !!!
  QUOTED = %w(title output xlabel x2label ylabel y2label clabel cblabel zlabel rgb)

  ##
  # ==== Overview
  # Recursive function that converts Ruby options to gnuplot
  # ==== Parameters
  # *option* - an option that should be converted
  # ==== Examples
  #   ['png', size: [300, 300]] => 'png size 300,300'
  #   0..100 => '[0:100]'
  def option_to_string(key = nil, option)
    return key.to_s if !!option == option # check for boolean
    value = case option
            when Array
              option.map { |el| option_to_string(el) }.join(option[0].is_a?(Numeric) ? ',' : ' ')
            when Hash
              option.map { |i_key, i_val| option_to_string(i_key, i_val) }.join(' ')
            when Range
              "[#{option.begin}:#{option.end}]"
            else
              option.to_s
            end
    value = "'#{value}'" if QUOTED.include?(key.to_s)
    value = "#{key} " + value if key
    value
  end
end

