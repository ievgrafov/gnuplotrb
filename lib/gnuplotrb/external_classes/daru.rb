if defined? Daru
  module Daru
    class DataFrame
      def to_gnuplot_points
        result = ''
        self.each_row_with_index do |row, index|
          result += "#{index.to_s} "
          result += row.to_a.join(' ')
          result += "\n"
        end
        result
      end
    end

    class Vector
      def to_gnuplot_points
        result = ''
        self.each_with_index do |value, index|
          result += "#{index} #{value}\n"
        end
        result
      end
    end
  end
end