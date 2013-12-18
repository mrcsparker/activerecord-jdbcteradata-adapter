require 'spec_helper'
require 'models/no_autoincrement_pk'

describe 'NoAutoincrementPkSpec' do
  it 'should be able to create a record and manually set the post_id' do
    CreateNoAutoincrementPks.up
    obj = NoAutoincrementPk.new
    obj.post_id = 12345
    obj.title = 'Sample title with 3 or more periods ...'
    obj.save.should be_true
    obj.reload
    obj.id.should eq(12345)
    found = NoAutoincrementPk.find(12345)
    found.id.should eq(12345)
    CreateNoAutoincrementPks.down
  end
end
