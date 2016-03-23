require 'spec_helper'
describe 'sys_conf' do

  context 'with defaults for all parameters' do
    it { should contain_class('sys_conf') }
  end
end
