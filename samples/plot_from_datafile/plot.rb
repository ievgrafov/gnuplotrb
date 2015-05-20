require 'gnuplot'
include Gnuplot

plot = Plot.new(['points.data', with: 'lines', title: 'Points from file'], term: ['qt', persist: true])

$RSPEC_TEST ? plot.to_png('./gnuplot_gem.png', size: [600, 600]) : plot.plot