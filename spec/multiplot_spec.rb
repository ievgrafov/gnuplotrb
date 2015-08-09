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
      @options = { title: @title, layout: [2, 2] }
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
      expect(@mp.send(:specific_option?, :layout)).to be_truthy
      expect(@mp.send(:specific_option?, :title)).to be_truthy
      expect(@mp.send(:specific_option?, :xrange)).to be_falsey
    end

    it 'should return Multiplot object' do
      new_options = { title: 'Another title', xrange: 1..5 }
      new_plot = @mp.options(new_options)
      expect(new_plot).to_not equal(@mp)
      expect(new_plot).to be_an_instance_of(Multiplot)
    end
  end

  context 'safe plot array update' do
    before :each do
      @sinx = Plot.new('sin(x)')
      @plot3d = Splot.new('sin(x)*cos(y)')
      @exp = Plot.new('exp(x)')
      @paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      @options0 = { term: ['png', size: [300, 300]], output: @paths[0] }
      @options1 = { term: ['png', size: [300, 300]], output: @paths[1] }
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

    it 'should allow to get plots using []' do
      mp = Multiplot.new(@sinx, @exp, @plot3d)
      (0..2).each { |i| expect(mp[i]).to be_equal(mp.plots[i]) }
      expect(mp[0..-1]).to be_eql(mp.plots)
    end
  end

  context 'destructive plot array update' do
    before :each do
      plots = [
        Plot.new('sin(x)'),
        Splot.new('sin(x)*cos(y)'),
        Plot.new('exp(x)')
      ]
      @mp = Multiplot.new(*plots, layout: [1, 3])
    end

    it 'should update plots in the existing Plot' do
      @mp.update!(0) do |plot|
        plot.options!(title: 'Updated plot')
        plot.replace_dataset!('exp(x)')
        plot[0].lw!(3)
      end
      expect(@mp[0].title).to eql('Updated plot')
      expect(@mp[0][0].data).to eql('exp(x)')
      expect(@mp[0][0].lw).to eql(3)
    end

    it 'should replace plot in the existing Multiplot' do
      plot = Plot.new('cos(x)', title: 'Second plot')
      expect(@mp.replace!(1, plot)).to equal(@mp)
      expect(@mp[1].title).to eql('Second plot')
      @mp[0] = Plot.new('cos(x)', title: 'First plot')
      expect(@mp[0].title).to eql('First plot')
    end

    it 'should add plots to the existing Multiplot' do
      plot = Plot.new('cos(x)', title: 'First plot')
      expect(@mp.add!(plot)).to equal(@mp)
      expect(@mp[0].title).to eql('First plot')
      expect(@mp.plots.size).to eql(4)
    end

    it 'should remove plot from the existing Multiplot' do
      plot = Plot.new('cos(x)', title: 'Last plot')
      expect(@mp.add!(-1, plot)).to equal(@mp)
      expect(@mp.plots.size).to eql(4)
      expect(@mp.remove!).to equal(@mp)
      expect(@mp.plots.size).to eql(3)
      expect(@mp.plots.last.title).to eql('Last plot')
    end
  end
end
