require '../helper'
include Gnuplot

x = (0..5).to_a
y = x.map {|xx| xx*xx }
points = [x, y]

Plot.new(['x*x', title: 'True curve'], [points, with: 'lines', title: 'Points'], term: ['qt', persist: true], xrange: 0..5).plot