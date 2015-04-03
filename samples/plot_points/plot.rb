require '../helper'
include Gnuplot

x = (0..5).to_a
y = x.map {|xx| xx*xx }
points = [x, y]

Plot.new([points, with: 'lines'], term: ['qt', persist: true]).plot