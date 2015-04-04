require '../helper'
include Gnuplot

Plot.new(['1.5*cos(t) - cos(30*t), 1.5*sin(t) - sin(30*t)', title: 'Parametric curve'], title: 'Parametric plot example', parametric: true, samples: 3000).to_png('./result.png', size: [500,500])