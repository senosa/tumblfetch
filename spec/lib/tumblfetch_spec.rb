require 'spec_helper'
require 'tumblfetch'

describe Tumblfetch do
  describe '.write_settings_template_to' do
    it 'should write correct template' do
      testIO = StringIO.new
      Tumblfetch.write_settings_template_to(testIO)
      expect(testIO.string).to eq Tumblfetch::SETTINGS_TEMPLATE
    end
  end
end
