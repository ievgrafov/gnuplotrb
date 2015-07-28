require 'spec_helper.rb'

describe Animation do
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
      @title = 'Animation spec'
      @formula =  %w(sin(x) cos(x) exp(-x))
      @plots = @formula.map { |f| Plot.new(f) }
      @plots << Splot.new('sin(x) * cos(y)')
      @options = { title: @title, layout: [2, 2] }
    end

    it 'should be created out of sequence of plots' do
      expect(Animation.new(*@plots)).to be_an_instance_of(Animation)
    end

    it 'should set options passed to constructor' do
      anim = Animation.new(*@plots, **@options)
      expect(anim).to be_an_instance_of(Animation)
      expect(anim.title).to eql(@title)
    end
  end

  context 'option handling' do
    before do
      @options = Hamster.hash(title: 'GnuplotRB::Animation', yrange: 0..3)
      @anim = Animation.new(**@options)
    end

    it 'should allow to get option value by name' do
      expect(@anim.title).to eql(@options[:title])
    end

    it 'should know which options are Animation specific' do
      right = [:size, :tiny, :animate, :background]
      wrong = [:layout, :title, :xrange, :term]
      right.each { |opt| expect(@anim.send(:specific_option?, opt)).to be_truthy }
      wrong.each { |opt| expect(@anim.send(:specific_option?, opt)).to be_falsey }
    end

    it 'should return Animation object' do
      new_options = { title: 'Another title', xrange: 1..5 }
      new_plot = @anim.options(new_options)
      expect(new_plot).to_not equal(@anim)
      expect(new_plot).to be_an_instance_of(Animation)
    end
  end

  context 'handling plots as container' do
    before :each do
      @sinx = Plot.new('sin(x)')
      @plot3d = Splot.new('sin(x)*cos(y)')
      @exp = Plot.new('exp(x)')
      @paths = (0..2).map { |i| File.join(@tmp_dir, "#{i}plot.gif") }
      @anim = Animation.new(@sinx, @plot3d, @exp)
    end

    it 'should allow to remove plot from animation' do
      Animation.new(@sinx, @exp).plot(@paths[0])
      @anim.remove_plot(1).plot(@paths[1])
      @anim.remove_frame(1).plot(@paths[2])
      expect(same_files?(*@paths)).to be_truthy
    end

    it 'should allow to add plot to animation' do
      Animation.new(@plot3d, @sinx, @plot3d, @exp).plot(@paths[0])
      @anim.add_plot(@plot3d).plot(@paths[1])
      @anim.add_frame(@plot3d).plot(@paths[2])
      expect(same_files?(*@paths)).to be_truthy
    end

    it 'should allow to replace plot in animation' do
      Animation.new(@plot3d, @exp).plot(@paths[0])
      @anim.replace_plot(@plot3d).plot(@paths[1])
      @anim.replace_frame(@plot3d).plot(@paths[2])
      expect(same_files?(*@paths)).to be_truthy
    end

    it 'should allow to update options of any plot in animation' do
      ttl = "Wow, it's sin(x)!"
      Animation.new(@sinx.title(ttl), @plot3d, @exp).plot(@paths[0])
      @anim.update_plot(0, title: ttl).plot(@paths[1])
      @anim.update_frame(0, title: ttl).plot(@paths[2])
      expect(same_files?(*@paths)).to be_truthy
    end

    it 'should allow to update datasets of any plot in animation' do
      ds_ttl = 'Some dataset'
      ttl = "Wow, it's sin(x)!"
      Animation.new(@sinx.update_dataset(title: ds_ttl).title(ttl), @plot3d, @exp).plot(@paths[0])
      @anim.update_plot(0, title: ttl) do |new_plot|
        new_plot.update_dataset(title: ds_ttl)
      end.plot(@paths[1])
      @anim.update_frame(0, title: ttl) do |new_plot|
        new_plot.update_dataset(title: ds_ttl)
      end.plot(@paths[2])
      expect(same_files?(*@paths)).to be_truthy
    end

    it 'should allow to get plots using []' do
      (0..2).each { |i| expect(@anim[i]).to be_equal(@anim.plots[i]) }
      expect(@anim[0..-1]).to be_eql(@anim.plots)
      (0..2).each { |i| expect(@anim[i]).to be_equal(@anim.frames[i]) }
      expect(@anim[0..-1]).to be_eql(@anim.frames)
    end
  end

  it 'should not use terminal other than gif' do
    anim = Animation.new(Plot.new('sin(x)'))
    terminals = %w(png dumb svg)
    terminals.each { |term| expect { anim.send("to_#{term}".to_sym) }.to raise_error(RuntimeError) }
  end

  it 'should output html to iruby' do
    anim = Animation.new(Plot.new('sin(x)'))
    expect(anim.to_iruby[0]).to eql('text/html')
  end
end
