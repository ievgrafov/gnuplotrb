File.open('tons_of_data', 'w') do |f|
  (1..10000000).each do |x|
    xx = x/100000.0
    yy = Math.exp(Math.sin(xx))
    f.puts "#{xx} #{yy}"
  end
end