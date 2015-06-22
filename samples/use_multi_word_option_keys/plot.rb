require 'pilot-gnuplot'
include Gnuplot

titles = %w{decade Build Test Deploy Overall}
data = [
    [1,  312, 525,  215, 1052],
    [2,  630, 1050, 441, 2121],
    [3,  315, 701,  370, 1386],
    [4,  312, 514,  220, 1046]
]
x = data.map(&:first)
datasets = (1..4).map do |col|
    y = data.map { |row| row[col] }
    Dataset.new([x, y], using: '2:xtic(1)', title: titles[col], file: true)
end

plot = Plot.new(
    *datasets,
    style_data: 'histograms',
    style_fill: 'pattern border',
    yrange: 0..2200,
    xlabel: 'Number of test',
    ylabel: 'Time, s',
    title: 'Time spent to run deploy pipeline',
    term: ['qt', persist: true]
)

$RSPEC_TEST ? plot.to_png('./gnuplot_gem.png', size: [600, 600]) : plot.plot
