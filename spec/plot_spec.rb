require 'spec_helper.rb'

describe Plot do
  context 'options handling' do
    it 'should allow to get option value' do
      title = 'Gnuplot::Plot'
      plot = Plot.new(title: title)
      expect(plot.title).to eql(title)
    end

    it 'should allow to safely set option value' do
      title = 'Gnuplot::Plot'
      plot = Plot.new
      new_plot = plot.title(title)
      expect(new_plot.title).to eql(title)
      expect(plot.title).to be_nil
    end

    it 'should allow to force set option value' do
      title = 'Gnuplot::Plot'
      plot = Plot.new
      plot.title!(title)
      expect(plot.title).to eql(title)
    end
  end
end