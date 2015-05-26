require 'spec_helper.rb'

describe Plot do
  context 'options handling' do
    before do
      @options = {title: 'Gnuplot::Plot', yrange: 0..3}
      @plot = Plot.new(**@options)
    end

    it 'should allow to get option value by name' do
      expect(@plot.title).to eql(@options[:title])
    end

    it 'should allow to safely set option value by name' do
      another_title = 'Some new titile'
      new_plot = @plot.title(another_title)
      expect(@plot).not_to equal(new_plot)
      expect(new_plot.title).to eql(another_title)
      expect(@plot.title).to eql(@options[:title])
    end

    it 'should allow to get terminal' do
      expect(@plot.terminal).to be_an_instance_of(Terminal)
    end

    it 'should allow to get all the options' do
      expect(@plot.options).to eql(@options)
    end

    it 'should allow to safely set several options at once' do
      new_options = {title: 'Another title', xrange: 1..5}
      new_plot = @plot.options(new_options)
      expect(new_plot).to_not equal(@plot)
      expect(new_plot).to be_an_instance_of(Plot)
      expect(new_plot.options).to eql(@options.merge(new_options))
    end
  end
end
