require 'spec_helper'
require_relative '../../lib/tumblfetch'

describe Tumblfetch do
  describe '.init' do
    context 'when ~/.tumblr does not exist' do
      it 'should print message running `tumblr`'
    end

    context 'when ~/.tumblr exist' do
      it 'should generate Tumblfetchfile'
    end

    context 'when given base-hostname argument' do
      it 'should generate correct Tumblfetchfile'
    end
  end
end
