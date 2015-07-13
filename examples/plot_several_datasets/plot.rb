require 'gnuplotrb'
include GnuplotRB

x = (0..5).to_a
y = x.map {|xx| xx*xx }
points = [x, y]

plot = Plot.new(['x*x', title: 'True curve'], [points, with: 'lines', title: 'Points'])

plot.to_png('./gnuplot_gem.png', size: [600, 600])
