require 'spec_helper.rb'

describe 'GnuplotRB::fit' do
  before(:all) do
    @tmp_dir = File.join('spec', 'tmp')
    Dir.mkdir(@tmp_dir)
    @datafile_path = File.join('spec', 'points.data')
    x = (1..100).map { |xx| xx / 10.0}
    y = x.map { |xx| 3.0 * Math.exp(xx / 3) }
    @data = [x, y]
  end

  after(:all) do
    FileUtils.rm_r(@tmp_dir)
  end

  context 'input' do
    it 'should take Dataset as input' do
      ds = Dataset.new(@data)
      expect(fit(ds)).to be_instance_of(Hash)
    end

    it 'should take Datablock as input' do
      db = Datablock.new(@data)
      expect(fit(db)).to be_instance_of(Hash)
      db_in_file = Datablock.new(@data, true)
      expect(fit(db_in_file)).to be_instance_of(Hash)
    end

    it 'should take something out of which Dataset may be constructed as input' do
      expect(fit(@data)).to be_instance_of(Hash)
      expect(fit(@datafile_path)).to be_instance_of(Hash)
    end
  end

  context "fitting data" do
    it 'should throw error in case of wrong input' do
      expect { fit(@data, formula: 'wrong_formula') }.to raise_error(GnuplotError)
    end
  end
end
