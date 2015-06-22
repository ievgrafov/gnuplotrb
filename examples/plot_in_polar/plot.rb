require 'pilot-gnuplot'
include Gnuplot

plot = Plot.new(['abs(sin(3*t))', with: 'filledcurves'], title: 'Plot in polar example', polar: true, samples: 1000, term: ['qt', persist: true])

$RSPEC_TEST ? plot.to_png('./gnuplot_gem.png', size: [600, 600]) : plot.plot
