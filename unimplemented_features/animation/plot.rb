throw(NotImplementedError, 'Not ready yet!')

require 'gnuplotrb'
include GnuplotRB

plots = (0..99).map do |i|
  angle = 2*Math::PI*i/100
  Plot.new(['sin(10.*x)*exp(-x)',               title: 'i = 10',       lw: 2],
           ["sin(10.*x)*exp(-x)*cos(#{angle})", title: "i = #{i/10.0}", lw: 2],
           title: 'Animation', xzeroaxes: true, xrange: 0..2, yrange: -0.7..0.9)
end
Animation.new(*plots).plot('./animation.gif')
