require 'spec_helper'

describe 'Connection' do
  it 'should create a connection' do
    ActiveRecord::Base.connection.execute('select * from dbc.tables')
    ActiveRecord::Base.connected?.should be_true
  end
end
