class CreateTestFiles < ActiveRecord::Migration
  def self.up
    create_table 'test_files' do |t|
      t.string 'name', :null => false
      t.binary 'data'
      t.timestamps
    end
  end

  def self.down
    drop_table 'test_files'
  end
end

class TestFile < ActiveRecord::Base
  self.table_name = 'test_files'
end
