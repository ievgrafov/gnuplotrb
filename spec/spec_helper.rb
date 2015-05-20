require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'gnuplot'
require 'digest'
require 'chunky_png'

include ChunkyPNG::Color

def compare_images(img1, img2)
  images = [
      ChunkyPNG::Image.from_file(img1),
      ChunkyPNG::Image.from_file(img2)
  ]
  diff = 0
  images.first.height.times do |y|
    images.first.row(y).each_with_index do |pixel, x|
      diff += 1 unless pixel == images.last[x,y]
    end
  end
  diff
end

