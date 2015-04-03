require 'spec_helper.rb'

describe Gnuplot do
  before do
    @awesome = true
  end

  it 'should be awesome' do
    expect(@awesome).to be_truthy
  end
end
