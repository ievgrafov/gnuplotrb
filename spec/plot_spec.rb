require 'spec_helper.rb'

describe Plot do
  before(:all) do
    @tmp_dir = File.join('spec', 'tmp')
    Dir.mkdir(@tmp_dir)
    @datafile_path = File.join('spec', 'points.data')
  end

  after(:all) do
    FileUtils.rm_rf(@tmp_dir)
  end

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
  end

  context 'modifying datasets' do
    before do
      @plot_math = Plot.new(['sin(x)', title: 'Just a sin'])
      @dataset = Dataset.new('exp(-x)')
      @plot_two_ds = Plot.new(['cos(x)'], ['x*x'])
      @options = {title: 'Example dataset'}
      @plot_datafile = Plot.new([@datafile_path])
      @data = [1, 2, 3, 4]
      @plot_data_inmemory = Plot.new([@data])
      @plot_data_tempfile = Plot.new([@data, file: true])
    end

    it 'should create new Plot when user adds a dataset' do
      new_plot = @plot_math.add_dataset(@dataset)
      expect(new_plot).to_not be_equal(@plot_math)
    end

    it 'should create new Plot when user removes a dataset' do
      new_plot = @plot_two_ds.remove_dataset
      expect(new_plot).to_not be_equal(@plot_two_ds)
    end

    it 'should remove dataset exactly at given position' do
      (0..1).each do |i|
        j = i == 0 ? 1 : 0
        new_plot = @plot_two_ds.remove_dataset(i)
        expect(new_plot.datasets[0].data).to be_eql(@plot_two_ds.datasets[j].data)
      end
    end

    it 'should create new Plot when user replaces a dataset' do
      new_plot = @plot_two_ds.replace_dataset(@dataset)
      expect(new_plot).to_not be_equal(@plot_two_ds)
    end

    it 'should remplace dataset exactly at given position' do
      (0..1).each do |i|
        new_plot = @plot_two_ds.replace_dataset(i, @dataset)
        expect(new_plot.datasets[i].data).to be_eql(@dataset.data)
      end
    end

    it 'should allow to update dataset at given position with options' do
      (0..1).each do |i|
        new_plot = @plot_two_ds.update_dataset(i, @options)
        expect(new_plot.datasets[i].options.to_h).to be_eql(@options)
        expect(new_plot.datasets[i]).to_not equal(@plot_two_ds.datasets[i])
      end
    end

    it 'should not update Plot if neither data nor options update needed' do
      # data and options are empty so no update needed
      expect(@plot_math.update_dataset).to be_equal(@plot_math)
      # dataset with math formula could not to be updated
      expect(@plot_math.update_dataset(data: @data)).to be_equal(@plot_math)
      # dataset with data from existing file could not to be updated
      expect(@plot_datafile.update_dataset(data: @data)).to be_equal(@plot_datafile)
    end

    it 'should create new Plot (and new datablock) if you update data stored in memory' do
      current = File.join(@tmp_dir, 'plot.png')
      updated = File.join(@tmp_dir, 'updated_plot.png')
      new_plot = @plot_data_inmemory.update_dataset(data: @data)
      expect(new_plot).to_not be_equal(@plot_data_inmemory)
      @plot_data_inmemory.to_png(current, size: [200,200])
      new_plot.to_png(updated, size: [200,200])
      expect(same_images?(current, updated)).to be_falsy
    end

    it 'should not create new Plot (and new datablock) if you update data stored in temp file' do
      old = File.join(@tmp_dir, 'old_plot.png')
      current = File.join(@tmp_dir, 'plot.png')
      updated = File.join(@tmp_dir, 'updated_plot.png')
      @plot_data_tempfile.to_png(old, size: [200,200])
      new_plot = @plot_data_tempfile.update_dataset(data: @data)
      expect(new_plot).to be_equal(@plot_data_tempfile)
      @plot_data_tempfile.to_png(current, size: [200,200])
      new_plot.to_png(updated, size: [200,200])
      expect(same_images?(current, updated)).to be_truthy
      expect(same_images?(current, old)).to be_falsy
    end

    it 'should allow to get datasets using []' do
      (0..1).each { |i| expect(@plot_two_ds[i]).to be_equal(@plot_two_ds.datasets[i]) }
      expect(@plot_two_ds[0..-1]).to be_eql(@plot_two_ds.datasets)
    end
  end

  context 'check #replot' do
    it 'should just call #plot when used on new Plot' do
      paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      Plot.new(['sin(x)'], term: ['png', size: [300,300]], output: paths[0]).plot
      Plot.new(['sin(x)'], term: ['png', size: [300,300]], output: paths[1]).replot
      expect(same_images?(*paths)).to be_truthy
    end

    it 'should replot when data in file updated' do
      new_file_path = File.join(@tmp_dir, 'points.data')
      FileUtils.cp(@datafile_path, new_file_path)
      paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      plot = Plot.new([new_file_path], term: ['png', size: [300,300]], output: paths[0])
      # plot png before data update
      plot.plot
      # copy png because new will be created under the same name
      FileUtils.cp(paths[0], paths[1])
      # update data
      File.open(new_file_path, 'a') { |f| f.puts("\n10 10") }
      # and replot png
      plot.replot
      expect(same_images?(*paths)).to be_falsy
    end

    it 'should replot when data in Datablock (tempfile) updated' do
      count = 10000
      x = count.times.map { |xx| xx / 100.0}
      y = x.map { |xx| (xx**2)*Math.sin(xx) }
      paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      plot = Plot.new([[x[0..count/2], y[0..count/2]], title: 'x^2*sin(x)', with: 'lines', file: true], term: ['png', size: [300,300]], output: paths[0])
      # plot png before data update
      plot.plot
      # copy png because new one will be created under the same name
      FileUtils.cp(paths[0], paths[1])
      # update data
      plot.update_dataset(data: [x[count/2..-1], y[count/2..-1]])
      # and replot png
      plot.replot
      expect(same_images?(*paths)).to be_falsy
    end
  end
end
