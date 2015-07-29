require 'spec_helper.rb'

describe GnuplotRB do
  it 'should be awesome' do
    expect(awesome?).to be_truthy
  end

  it 'should know its version' do
    expect(Settings.version).to be_a(Numeric)
  end

  context 'check examples' do
    samples = Dir.glob('./examples/*plot*')
    samples.each do |path|
      name = path[11..-1]
      it "should work with #{name} example" do
        expect(run_example_at path).to be_truthy
      end
    end
  end
end
