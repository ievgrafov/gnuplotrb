require 'gnuplotrb'
include GnuplotRB

plot = Plot.new(['abs(sin(3*t))', with: 'filledcurves'], title: 'Plot in polar example', polar: true, samples: 1000)

plot.to_png('./gnuplot_gem.png', size: [600, 600])
