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

  context 'handling plots as container' do
    before :each do
      @sinx = Plot.new('sin(x)')
      @plot3d = Splot.new('sin(x)*cos(y)')
      @exp = Plot.new('exp(x)')
      @paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      @options0 = { term: ['png', size: [300,300]], output: @paths[0] }
      @options1 = { term: ['png', size: [300,300]], output: @paths[1] }
    end

    it 'should allow to remove plot from Mp' do
      mp = Multiplot.new(@sinx, @plot3d, @exp)
      updated_mp = mp.remove_plot(1)
      expect(mp).to_not equal(updated_mp)
      updated_mp.plot(@options0)
      Multiplot.new(@sinx, @exp).plot(@options1)
      expect(same_images?(*@paths)).to be_truthy      
    end

    it 'should allow to add plot to Mp' do
      mp = Multiplot.new(@sinx, @exp)
      updated_mp = mp.add_plot(@plot3d)
      expect(mp).to_not equal(updated_mp)
      updated_mp.plot(@options0)
      Multiplot.new(@plot3d, @sinx, @exp).plot(@options1)
      expect(same_images?(*@paths)).to be_truthy
    end

    it 'should allow to replace plot in Mp' do
      mp = Multiplot.new(@sinx, @exp)
      updated_mp = mp.replace_plot(@plot3d)
      expect(mp).to_not equal(updated_mp)
      updated_mp.plot(@options0)
      Multiplot.new(@plot3d, @exp).plot(@options1)
      expect(same_images?(*@paths)).to be_truthy
    end

    it 'should allow to update options of any plot in mp' do
      ttl = "Wow, it's sin(x)!"
      mp = Multiplot.new(@sinx, @exp)
      updated_mp = mp.update_plot(0, title: ttl)
      expect(mp).to_not equal(updated_mp)
      updated_mp.plot(@options0)
      Multiplot.new(@sinx.title(ttl), @exp).plot(@options1)
      expect(same_images?(*@paths)).to be_truthy
    end

    it 'should allow to update datasets of any plot in mp' do
      ds_ttl = 'Some dataset'
      ttl = "Wow, it's sin(x)!"
      mp = Multiplot.new(@sinx, @exp)
      updated_mp = mp.update_plot(0, title: ttl) do |new_plot|
        new_plot.update_dataset(title: ds_ttl)
      end
      expect(mp).to_not equal(updated_mp)
      updated_mp.plot(@options0)
      udpdated_sinx = @sinx.title(ttl).update_dataset(title: ds_ttl)
      Multiplot.new(udpdated_sinx, @exp).plot(@options1)
      expect(same_images?(*@paths)).to be_truthy
    end
  end
end
