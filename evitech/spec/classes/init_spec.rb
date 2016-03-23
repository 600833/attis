require 'spec_helper'
describe 'evitech' do

  context 'with defaults for all parameters' do
    it { should contain_class('evitech') }
  end
end
