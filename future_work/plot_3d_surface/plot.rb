throw(NotImplementedError, 'Not ready yet!')

double_pi = Math.PI * 2
Splot.new('cos(x)*cos(y)', xrange: -double_pi..double_pi, yrange: -double_pi..double_pi, term: ['qt', size: [500, 500], persist: true], style: 'function lp', hidden3d: true).plot