require 'spec_helper.rb'

describe Terminal do
  before(:all) do
    @tmp_dir = File.join('spec', 'tmp')
    Dir.mkdir(@tmp_dir)
    @datafile_path = File.join('spec', 'points.data')
  end

  after(:all) do
    FileUtils.rm_rf(@tmp_dir)
  end

  before do
    @terminal = Terminal.new
    @paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
    @options0 = { term: ['png', size: [300,300]], output: @paths[0] }
    @options1 = { term: ['png', size: [300,300]], output: @paths[1] }
    @dataset = Dataset.new('sin(x)')
    @plot = Plot.new(@dataset, @options0)
  end

  context 'options handling' do

    it 'should work with String as option value' do
      options = {term: 'qt'}
      string = @terminal.options_hash_to_string(options)
      expect(string.strip).to be_eql("set term qt")
    end

    it 'should work with Boolean and nil as option value' do
      [[{multiplot: true}, "set multiplot"],
       [{multiplot: false}, "unset multiplot"],
       [{multiplot: nil}, "unset multiplot"]].each do |variant|
         string = @terminal.options_hash_to_string(variant[0])
         expect(string.strip).to be_eql(variant[1])
      end
    end

    it 'should work with Array and Hash as option value' do
      # it works with arrays of numbers different way
      options = {term: ['qt', size: [100, 100]]}
      string = @terminal.options_hash_to_string(options)
      expect(string.strip).to be_eql("set term qt size 100,100")
    end
  end

  context '#<<' do
    it 'should output Plots' do
      @plot.plot
      FileUtils.mv(@paths[0], @paths[1])
      @terminal << @plot
      expect(same_images?(*@paths)).to be_truthy
    end

    it 'should output Datasets' do
      @plot.plot
      @terminal.set(@options1)
      @terminal << @dataset
      expect(same_images?(*@paths)).to be_truthy
    end

    it 'should output whatever you want just as string' do
      @plot.plot
      @terminal << @terminal.options_hash_to_string(@options1)
      @terminal << @dataset
      expect(same_images?(*@paths)).to be_truthy
    end
  end

  context '#puts' do
    it 'should output whatever you want just as string' do
      @plot.plot
      @terminal.puts(@terminal.options_hash_to_string(@options1))
      @terminal << @dataset
      expect(same_images?(*@paths)).to be_truthy
    end
  end

  context '#replot' do
    it 'should replot last plotted graph on #replot call' do
      @plot.plot(@terminal)
      @terminal.replot(@options1)
      expect(same_images?(*@paths)).to be_truthy
    end
  end
end
