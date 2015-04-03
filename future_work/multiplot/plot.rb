throw(NotImplementedError, 'Not ready yet!')

titles = %w{decade Austria Hungary  Belgium}
data = [
    ['1891-1900',  234081,  181288,  18167],
    ['1901-1910',  668209,  808511,  41635],
    ['1911-1920',  453649,  442693,  33746],
    ['1921-1930',  32868,   30680,   15846],
    ['1931-1940',  3563,    7861,    4817],
    ['1941-1950',  24860,   3469,    12189],
    ['1951-1960',  67106,   36637,   18575],
    ['1961-1970',  20621,   5401,    9192],
]
x = data.map(&:first)
plots = (1..3).map do |col|
  y = data.map { |row| row[col] }
  Plot.new([[x, y], using: '2:xtic(1)'], title: titles[col])
end
Multiplot.new(*plots, layout: [plots.size, 1], style: 'data histograms', xtics: 'nomirror rotate by -45', term: ['qt', persist: true]).plot