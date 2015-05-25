require 'spec_helper.rb'

describe Gnuplot do
  it 'should be awesome' do
    expect(awesome?).to be_truthy
  end

  context 'check plots' do
    samples = Dir.glob('./samples/plot*')
    samples.each do |path|
      it "should pass #{path} test" do
        Dir.chdir(path) do
          require "#{Dir.pwd}/plot.rb"
          system('gnuplot plot.gnuplot')
          expect(same_images?('gnuplot.png', 'gnuplot_gem.png')).to be_truthy
        end
      end
    end
  end
end
