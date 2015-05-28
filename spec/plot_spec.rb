require 'spec_helper.rb'

describe Plot do
  context 'creation' do
    before do
      @title = 'Awesome spec'
      @formula =  %w(sin(x) cos(x) exp(-x))
      @options = {title: @title, term: 'dumb'}
    end

    it 'should be created out of sequence of datasets' do
      datasets = @formula.map { |formula| Dataset.new(formula) }
      expect(Plot.new(*datasets)).to be_an_instance_of(Plot)
    end

    it 'should be created out of sequence of arrays' do
      expect(Plot.new(*@formula)).to be_an_instance_of(Plot)
    end

    it 'should set options passed to constructor' do
      plot = Plot.new(*@formula, **@options)
      expect(plot).to be_an_instance_of(Plot)
      expect(plot.title).to eql(@title)
    end
  end

  context 'options handling' do
    before do
      @options = Hamster.hash(title: 'Gnuplot::Plot', yrange: 0..3)
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
    # TODO add specs for different options types (hash/array/bool/string/range)
  end
end
