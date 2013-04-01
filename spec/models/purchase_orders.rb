class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.string :name, :limit => 50, :null => false
      t.string :catch_phrase, :null => true
    end
    add_index :vendors, :name
  end

  def self.down
    drop_table :vendors
  end
end

class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, :limit => 50, :null => false
      t.integer :vendor_id, :null => false
      t.float :price, :default => 0.0, :null => false
    end
    add_index :products, :name
    add_index :products, :vendor_id
  end

  def self.down
    drop_table :products
  end
end

class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.string :code, :limit => 50, :null => false
      t.integer :quantity, :default => 0, :null => false
      t.integer :product_id, :null => false
    end

    add_index :purchase_orders, :product_id, :name => 'idx_purchase_orders_product_id'
  end

  def self.down
    drop_table :purchase_orders
  end
end

class Vendor < ActiveRecord::Base
  has_many :products
  has_many :purchase_orders, :through => :products
end

class Product < ActiveRecord::Base
  belongs_to :vendor
  has_many :purchase_orders
end

class PurchaseOrder < ActiveRecord::Base
  belongs_to :product
end
