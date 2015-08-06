require 'spec_helper.rb'

describe Dataset do
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
      x = (0..10).to_a
      y = x.map { |xx| Math.exp(-xx) }
      @data = [x, y]
    end

    it 'may be created with math function as data' do
      dataset = Dataset.new('sin(x)')
      expect(dataset.to_s).to eql('sin(x) ')
    end

    it 'may be created with datafile as data' do
      dataset = Dataset.new('spec/points.data')
      expect(dataset.to_s).to eql("'spec/points.data' ")
    end

    it 'may be created with some class with #to_points' do
      dataset = Dataset.new(@data)
      expect(dataset.data).to be_an_instance_of(Datablock)
      expect(dataset.to_s(Terminal.new)).to eql('$DATA1 ')
    end

    it 'may be created with clone of existing datablock as data' do
      datablock = Datablock.new(@data)
      dataset = Dataset.new(datablock)
      expect(dataset.data).to be_an_instance_of(Datablock)
      expect(datablock).to_not equal(dataset.data) # given datablock should be cloned
    end

    it 'may be created with existing stored in file datablock' do
      datablock = Datablock.new(@data, true)
      dataset = Dataset.new(datablock)
      expect(dataset.data).to be_an_instance_of(Datablock)
      # since given datablock's data stored in file, it should not be cloned
      expect(datablock).to equal(dataset.data)
      expect(dataset.to_s(Terminal.new)).to eql("#{datablock.name} ")
    end

    it 'may be created with given gnuplot options' do
      dataset = Dataset.new(@data, title: 'Dataset title', with: 'linespoints')
      expect(dataset.to_s(Terminal.new)).to eql("$DATA1 title \"Dataset title\" with linespoints")
    end

    it 'may be created with special :file option' do
      # {:file => true} will force creation of stored in file datablock
      dataset = Dataset.new(@data, title: 'Dataset title', file: true)
      expect(dataset.data.name).to match(/tmp_data/)
      expect(dataset.to_s).to eql("#{dataset.data.name} title \"Dataset title\"")
    end
  end

  context 'creation with Daru' do
    before do
      @xtic = %w(1991 1993 1995 1997)
      @y =    [2453, 2343, 2454, 2254]
      @yerr = [120,  133,  123,  113]
      @title = :plot_from_daru
      @data = (0..3).map { |i| "\"#{@xtic[i]}\" #{@y[i]} #{@yerr[i]}\n" }.join
      @df = Daru::DataFrame.new([@y, @yerr], order: [:y, :yerr], index: @xtic, name: @title)
      @alt_title = 'Some other given title'
      @vector = Daru::Vector.new(@y, index: @xtic, name: @title)
    end

    it 'may be created with Daru::Vector given' do
      ds = Dataset.new(@vector)
      expect(ds.title).to eql(@title)
      expect(ds.using).to eql('2:xtic(1)')
      data = (0..3).map { |i| "\"#{@xtic[i]}\" #{@y[i]}\n" }.join
      expect(ds.data.instance_variable_get(:@data)).to eql(data)
    end

    it 'may be created with Daru::DataFrame given' do
      ds = Dataset.new(@df)
      expect(ds.title).to eql(@title)
      expect(ds.using).to eql('2:3:xtic(1)')
      expect(ds.data.instance_variable_get(:@data)).to eql(@data)
    end

    it "should use given title instead of Daru's" do
      expect(Dataset.new(@vector, title: @alt_title).title).to eql(@alt_title)
      expect(Dataset.new(@df, title: @alt_title).title).to eql(@alt_title)
    end

    it 'may be created with Daru::DataFrame and *using* option given' do
      ds = Dataset.new(@df, using: 'index:yerr:xtic(y)')
      expect(ds.using).to eql('1:3:xtic(2)')
      expect(ds.data.instance_variable_get(:@data)).to eql(@data)
    end
  end

  context 'options handling' do
    before do
      @options = Hamster.hash(title: 'GnuplotRB::Dataset', with: 'lines')
      @dataset = Dataset.new('sin(x)', @options)
    end

    it 'should allow to get option value by name' do
      @options.each { |key, value| expect(@dataset.send(key)).to eql(value) }
    end

    it 'should allow to safely set option value by name' do
      new_with = 'points'
      new_dataset = @dataset.with(new_with)
      expect(@dataset.with).to equal(@options[:with])
      expect(new_dataset.with).to equal(new_with)
    end

    it 'should allow to get all the options' do
      expect(@dataset.options).to eql(@options)
    end

    it 'should allow to safely set several options at once' do
      new_options = Hamster.hash(title: 'Some new title', with: 'lines', lt: 3)
      new_dataset = @dataset.options(new_options)
      @options.each { |key, value| expect(@dataset.send(key)).to eql(value) }
      new_options.each { |key, value| expect(new_dataset.send(key)).to eql(value) }
    end
  end

  context 'safe update' do
    before do
      x = (0..10).to_a
      y = x.map { |xx| Math.exp(-xx) }
      @data = [x, y]
      @options = Hamster.hash(title: 'GnuplotRB::Dataset', with: 'lines')
      @sinx = Dataset.new('sin(x)', @options)
      @dataset = Dataset.new([x, y])
      @temp_file_dataset = Dataset.new([x, y], file: true)
    end

    it 'should update options' do
      # works just as Dataset#options(...)
      new_options = Hamster.hash(title: 'Some new title', with: 'lines', lt: 3)
      new_dataset = @sinx.update(new_options)
      @options.each { |key, value| expect(@sinx.send(key)).to eql(value) }
      new_options.each { |key, value| expect(new_dataset.send(key)).to eql(value) }
    end

    it 'should do nothing if no options given and no data update needed' do
      expect(@dataset.update).to equal(@dataset)
      expect(@sinx.update('some new data')).to equal(@sinx)
    end

    it 'should update if options are given and no data update needed' do
      updated = @dataset.update(@options)
      expect(updated).to_not equal(@dataset)
      @options.each { |key, value| expect(updated.send(key)).to eql(value) }
    end

    it 'should update datablock stored in here-doc' do
      updated = @dataset.update(@data)
      expect(updated.data).to_not equal(@dataset.data)
    end

    it 'should update datablock stored in temp file' do
      filename = @temp_file_dataset.data.name[1..-2] # avoid '' on ends
      size_before_update = File.size(filename)
      updated = @temp_file_dataset.update(@data)
      size_after_update = File.size(filename)
      expect(updated.data).to equal(@temp_file_dataset.data)
      expect(size_after_update).to be > size_before_update
    end
  end

  context 'destructive update' do
    before :each do
      x = (0..10).to_a
      y = x.map { |xx| Math.exp(-xx) }
      @data = [x, y]
      @ds = Dataset.new(@data)
      @ds_file = Dataset.new(@data, file: true)
    end

    it 'should update an option of existing object' do
      expect(@ds.lw!(3)).to equal(@ds)
      expect(@ds.lw).to eql(3)
      @ds.pt = 8
      expect(@ds.pt).to eql(8)
    end

    it 'should update several options of existing object at once via #options!' do
      expect(@ds.options!(lw: 3, pt: 8)).to equal(@ds)
      expect(@ds.lw).to eql(3)
      expect(@ds.pt).to eql(8)
    end

    it 'should update several options of existing object at once via #update!' do
      expect(@ds.update!(lw: 3, pt: 8)).to equal(@ds)
      expect(@ds.lw).to eql(3)
      expect(@ds.pt).to eql(8)
    end

    it 'should update data of existing in-memory datablock at once' do
      paths = (0..1).map { |i| File.join(@tmp_dir, "#{i}plot.png") }
      options0 = { term: ['png', size: [300, 300]], output: paths[0] }
      options1 = { term: ['png', size: [300, 300]], output: paths[1] }
      x1 = (11..15).to_a
      y1 = x1.map { |xx| Math.exp(-xx) }
      @ds.plot(options0)
      expect(@ds.update!([x1, y1])).to equal(@ds)
      @ds.plot(options1)
      expect(same_images?(*paths)).to be_falsey
    end

    it 'should update data of existing in-file datablock at once' do
      x1 = (11..15).to_a
      y1 = x1.map { |xx| Math.exp(-xx) }
      size_before = File.size(@ds_file.data.to_s[1..-2])
      expect(@ds_file.update!([x1, y1])).to equal(@ds_file)
      size_after = File.size(@ds_file.data.to_s[1..-2])
      expect(size_after).to be > size_before
    end
  end
end
