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
    return self.clone
  end
end