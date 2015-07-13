require 'gnuplotrb'
include GnuplotRB

plot = Plot.new(['points.data', with: 'lines', title: 'Points from file'])

plot.to_png('./gnuplot_gem.png', size: [600, 600])