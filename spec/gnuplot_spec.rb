require 'spec_helper.rb'
require 'digest'

describe Gnuplot do
  before do
    @awesome = true
  end

  it 'should be awesome' do
    expect(@awesome).to be_truthy
  end

  it 'should plot just as gnuplot itself' do
    Dir.chdir('spec/plot_to_image_file') do
      require 'plot_to_image_file/plot.rb'
      system('gnuplot plot.gnuplot')
      gnuplot_md5 = Digest::MD5.hexdigest(File.read('gnuplot.png'))
      gem_md5 = Digest::MD5.hexdigest(File.read('gnuplot_gem.png'))
      expect(gnuplot_md5).to eq(gem_md5)
    end
  end
end
