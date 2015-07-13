require 'gnuplotrb'
include GnuplotRB

plot = Plot.new(['1.5*cos(t) - cos(30*t), 1.5*sin(t) - sin(30*t)', title: 'Parametric curve'], title: 'Parametric plot example', parametric: true, samples: 3000)

plot.to_png('./gnuplot_gem.png', size: [600, 600])
