require 'spec_helper.rb'

describe Terminal do
  before do
    @terminal = Terminal.new
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
end
