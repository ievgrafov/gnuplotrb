require 'spec_helper.rb'

describe Splot do
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
      @title = 'Awesome spec'
      @formula =  %w(sin(x) cos(x) exp(-x))
      @options = { title: @title, term: 'dumb' }
    end

    it 'should use *splot* command instead of *plot*' do
      plot = Splot.new(*@formula, **@options)
      expect(plot).to be_an_instance_of(Splot)
      expect(plot.instance_variable_get(:@cmd)).to eql('splot ')
    end
  end

  context 'options handling' do
    before do
      @options = Hamster.hash(title: 'GnuplotRB::Plot', yrange: 0..3)
      @plot = Splot.new(**@options)
    end

    it 'should return Splot object' do
      new_options = { title: 'Another title', xrange: 1..5 }
      new_plot = @plot.options(new_options)
      expect(new_plot).to_not equal(@plot)
      expect(new_plot).to be_an_instance_of(Splot)
    end
  end

  context 'modifying datasets' do
    before do
      @plot_math = Splot.new(['sin(x)', title: 'Just a sin'])
      @dataset = Dataset.new('exp(-x)')
      @plot_two_ds = Splot.new(['cos(x)'], ['x*x'])
    end

    it 'should create new *Splot* when user adds a dataset' do
      new_plot = @plot_math.add_dataset(@dataset)
      expect(new_plot).to be_instance_of(Splot)
    end

    it 'should create new *Splot* when user adds a dataset using #<<' do
      new_plot = @plot_math << @dataset
      expect(new_plot).to be_instance_of(Splot)
    end

    it 'should create new *Splot* when user removes a dataset' do
      new_plot = @plot_two_ds.remove_dataset
      expect(new_plot).to be_instance_of(Splot)
    end
  end
end
