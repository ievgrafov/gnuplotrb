require '../helper'
include Gnuplot

Plot.new(['x*sin(x)', with: 'lines', lw: 4], xrange: -10..10, title: 'Math function example', ylabel: 'x', xlabel: 'x*sin(x)', term: ['qt', persist: true]).plot