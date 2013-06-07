class CreateShirts < ActiveRecord::Migration
  def self.up
    create_table 'SHIRTS' do |t|
      t.string 'COLOR', :null => false
      t.string 'STATUS_CODE', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table 'SHIRTS'
  end
end

class Shirt < ActiveRecord::Base
  self.table_name = 'SHIRTS'
end
