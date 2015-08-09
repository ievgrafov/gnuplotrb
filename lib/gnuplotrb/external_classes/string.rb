##
# Methods to take data for GnuplotRB plots.
class String
  # @return [String] data converted to Gnuplot format
  alias_method :to_gnuplot_points, :clone
end
