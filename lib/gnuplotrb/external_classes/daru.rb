if defined? Daru
  ##
  # See [daru](https://github.com/v0dro/daru)
  module Daru
    ##
    # Methods to take data for GnuplotRB plots.
    class DataFrame
      def to_gnuplot_points
        result = ''
        each_row_with_index do |row, index|
          quoted = index.is_a?(String) || index.is_a?(Symbol)
          result += quoted ? "\"#{index}\" " : "#{index} "
          result += row.to_a.join(' ')
          result += "\n"
        end
        result
      end
    end

    ##
    # Methods to take data for GnuplotRB plots.
    class Vector
      def to_gnuplot_points
        result = ''
        each_with_index do |value, index|
          quoted = index.is_a?(String) || index.is_a?(Symbol)
          result += quoted ? "\"#{index}\" " : "#{index} "
          result += "#{value}\n"
        end
        result
      end
    end
  end
end
