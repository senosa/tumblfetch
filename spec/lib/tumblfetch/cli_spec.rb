require 'spec_helper'
require 'tumblfetch/cli'

describe CLI do
  describe '#version' do
    it 'should print version' do
      capture(:stdout) do
        CLI.new.invoke('version')
      end.strip.should eq Tumblfetch::VERSION
    end
  end
end
