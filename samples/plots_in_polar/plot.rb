require '../helper'
include Gnuplot

Plot.new(['abs(sin(3*t))', with: 'filledcurves'], title: 'Plot in polar example', polar: true, samples: 1000).to_png('./result.png', size: [700,700])