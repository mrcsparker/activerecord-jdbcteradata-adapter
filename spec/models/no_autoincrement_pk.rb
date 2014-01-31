class CreateNoAutoincrementPks < ActiveRecord::Migration
  def self.up
    create_table :no_autoincrement_pks, :id => false do |t|
      t.integer :post_id
      t.string :title
      t.timestamps
    end
  end

  def self.down
    drop_table :no_autoincrement_pks
  end
end

class NoAutoincrementPk < ActiveRecord::Base
  self.primary_key = 'post_id'
end
