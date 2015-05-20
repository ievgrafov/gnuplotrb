require 'pilot-gnuplot'
include Gnuplot

plot = Plot.new(['1.5*cos(t) - cos(30*t), 1.5*sin(t) - sin(30*t)', title: 'Parametric curve'], title: 'Parametric plot example', parametric: true, samples: 3000, term: ['qt', persist: true])

$RSPEC_TEST ? plot.to_png('./gnuplot_gem.png', size: [600, 600]) : plot.plot
