if defined? Daru
  ##
  # See {daru}[https://github.com/v0dro/daru] and
  # {plotting from daru}[https://github.com/dilcom/gnuplotrb/blob/master/notebooks/plotting_from_daru.ipynb]
  module Daru
    ##
    # Methods to take data for GnuplotRB plots.
    class DataFrame
      ##
      # Convert DataFrame to Gnuplot format.
      #
      # @return [String] data converted to Gnuplot format
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
      ##
      # Convert Vector to Gnuplot format.
      #
      # @return [String] data converted to Gnuplot format
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
