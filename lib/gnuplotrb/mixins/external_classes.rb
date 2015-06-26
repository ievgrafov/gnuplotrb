class Array
  # taken for example from current gnuplot bindings
  def to_gnuplot_points
    return '' if self.empty?
    case self[0]
    when Array
      self[0].zip(*self[1..-1]).map { |a| a.join(' ') }.join("\n")
    when Numeric
      join("\n")
    else
      self[0].zip(*self[1..-1]).to_points
    end
  end
end

class String
  def to_gnuplot_points
    clone
  end
end

##
# Very immature way of implementing Daru plots
# Should be improved!
module Daru
  class DataFrame
    def to_gnuplot_points
      self.to_matrix
          .to_a
          .inject('') { |result, row| result + row.join(' ') + "\n" }
    end
  end
end