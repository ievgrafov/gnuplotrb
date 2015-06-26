require 'spec_helper.rb'

describe Multiplot do
  before(:all) do
    @tmp_dir = File.join('spec', 'tmp')
    Dir.mkdir(@tmp_dir)
    @datafile_path = File.join('spec', 'points.data')
  end

  after(:all) do
    FileUtils.rm_r(@tmp_dir)
  end

  context 'creation' do
    before do
      @title = 'Multiplot spec'
      @formula =  %w(sin(x) cos(x) exp(-x))
      @plots = @formula.map { |f| Plot.new(f) }
      @plots << Splot.new('sin(x) * cos(y)')
      @options = {title: @title, layout: [2,2]}
    end

    it 'should be created out of sequence of plots' do
      expect(Multiplot.new(*@plots)).to be_an_instance_of(Multiplot)
    end

    it 'should set options passed to constructor' do
      mp = Multiplot.new(*@plots, **@options)
      expect(mp).to be_an_instance_of(Multiplot)
      expect(mp.title).to eql(@title)
    end
  end

  context 'option handling' do
    before do
      @options = Hamster.hash(title: 'GnuplotRB::Multiplot', yrange: 0..3)
      @mp = Multiplot.new(**@options)
    end

    it 'should allow to get option value by name' do
      expect(@mp.title).to eql(@options[:title])
    end

    it 'should know which options are Multiplot special' do
      expect(@mp.mp_option?(:layout)).to be_truthy
      expect(@mp.mp_option?(:title)).to be_truthy
      expect(@mp.mp_option?(:xrange)).to be_falsey
    end

    it 'should return Multiplot object' do
      new_options = {title: 'Another title', xrange: 1..5}
      new_plot = @mp.options(new_options)
      expect(new_plot).to_not equal(@mp)
      expect(new_plot).to be_an_instance_of(Multiplot)
    end
  end
  # TODO: specs for modifying array of plots
end
