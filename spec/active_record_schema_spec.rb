require 'spec_helper'

require 'models/active_record_schema'

describe 'ActiveRecordSchemaSpec' do
  it 'should load in the activerecord sample schema.rb file' do
    expect {
      CreateActiveRecordSchema.up
    }.to_not raise_error
  end
end
