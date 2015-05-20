require 'spec_helper.rb'

$RSPEC_TEST = true

describe Gnuplot do
  before do
    @awesome = true
  end

  it 'should be awesome' do
    expect(@awesome).to be_truthy
  end

  context 'check plots' do
    samples = Dir.glob('./samples/plot*')
    samples.each do |path|
      it "should pass #{path} test" do
        Dir.chdir(path) do
          require "#{Dir.pwd}/plot.rb"
          system('gnuplot plot.gnuplot')
          expect(compare_images('gnuplot.png', 'gnuplot_gem.png')).to eq(0)
        end
      end
    end
  end
end
