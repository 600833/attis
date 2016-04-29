require 'spec_helper'
describe 'attis' do

  context 'with defaults for all parameters' do
    it { should contain_class('attis') }
  end
end
