throw(NotImplementedError, 'Not ready yet!')

plots = (0..99).map do |i|
  angle = 2*Math.Pi*i/100
  Plot.new(['sin(10.*x)*exp(-x)',               title: 'i = 10',       lw: 2],
           ["sin(10.*x)*exp(-x)*cos(#{angle})", title: "i = #{i*3.6}", lw: 2],
           title: 'Animation', xzeroaxes: true, xrange: 0..2, yrange: -0.7..0.9)
end
Animation.new(*plots).plot('./animation.gif', delay: 10, size: [300, 300])