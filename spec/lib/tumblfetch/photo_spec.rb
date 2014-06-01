require 'spec_helper'
require 'tumblfetch/photo'

describe Tumblfetch::Photo, '.new' do
  subject { Tumblfetch::Photo.new(
    post_id: 123,
    link_url: 'TheURL',
    photoset_idx: 0,
    hash: 'PhotoHash'
    )
  }
  it { should be_a Tumblfetch::Photo }
  its(:post_id) { should eq 123 }
  its(:link_url) { should include 'TheURL' }
  its(:photoset_idx) { should eq 0 }
  its(:hash) { should eq 'PhotoHash'}

  context 'when link_url is nil' do
    subject { Tumblfetch::Photo.new(
      link_url: nil,
      post_id: 456,
      photoset_idx: 2,
      hash: 'PhotoHash'
      )
    }
    its(:link_url) { should be_nil }
  end
end
