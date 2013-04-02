require 'spec_helper'

require 'models/active_record_schema'
require 'models/active_record_models'

describe 'ActiveRecordSchemaSpec' do
  it 'should load in the activerecord sample schema.rb file' do
    expect {
      CreateActiveRecordSchema.up
    }.to_not raise_error
  end

  context 'from loaded activerecord data' do
    before(:all) do
      CreateActiveRecordSchema.up
      Topic.delete_all

      1.upto(4) do |i|
        @topic = Topic.new
        @topic.title = "foo#{i}"
        @topic.author_name = "author#{i}"
        @topic.author_email_address = "email#{i}@localhost"
        @topic.approved = true
        @topic.save
      end
    end

    it 'should be able to group data' do
      topic = Topic.last
      topic.approved = false
      topic.save
    end

    approved_topics_count = Topic.group(:approved).count(:author_name)[true]
    approved_topics_count.should == 3
  end
end
