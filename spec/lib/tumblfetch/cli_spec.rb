require 'spec_helper'
require 'tumblfetch/cli'

describe CLI do
  describe '#version' do
    subject { capture(:stdout) { CLI.new.invoke('version') }.strip }
    it { should be_eql Tumblfetch::VERSION }
  end
end
