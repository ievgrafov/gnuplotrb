##
# Methods to take data for GnuplotRB plots.
class Array
  # taken for example from current gnuplot bindings
  # @return [String] array converted to Gnuplot format
  def to_gnuplot_points
    return '' if self.empty?
    case self[0]
    when Array
      self[0].zip(*self[1..-1]).map { |a| a.join(' ') }.join("\n")
    when Numeric
      join("\n")
    else
      self[0].zip(*self[1..-1]).to_gnuplot_points
    end
  end
end
