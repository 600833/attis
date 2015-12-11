require 'spec_helper'
describe 'vli' do

  context 'with defaults for all parameters' do
    it { should contain_class('vli') }
  end
end
