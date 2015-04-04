set title 'Parametric plot example'
set parametric
set samples 3000
set term png size 500,500
set output './result.png'
plot 1.5*cos(t) - cos(30*t), 1.5*sin(t) - sin(30*t) title 'Parametric curve'