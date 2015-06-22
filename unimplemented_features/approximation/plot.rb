throw(NotImplementedError, 'Not ready yet!')

require '../helper'
include GnuplotRB

Approximation.new('points.data', 'a2*x*x+a1*x+a0', using: '1:2:3', via: [:a2, :a1, :a0]).to_qt(persist: true)