require '../helper'
include Gnuplot

Plot.new(['points.data', with: 'lines', title: 'Points from file'], term: ['qt', persist: true]).plot