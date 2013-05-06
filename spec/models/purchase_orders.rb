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

class CreateOrderLineItems < ActiveRecord::Migration
  def self.up
    create_table :order_line_items do |t|
      t.integer :purchase_order_id, :null => false
      t.string :item_name, :null => false
    end

    add_index :order_line_items, :purchase_order_id, :name => 'idx_line_items_po_id'
  end

  def self.down
    drop_table :order_line_items
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

class OrderLineItem < ActiveRecord::Base
  belongs_to :purchase_order
end

class PurchaseOrder < ActiveRecord::Base
  belongs_to :product
  has_many :order_line_items, :dependent => :destroy
  accepts_nested_attributes_for :order_line_items, :allow_destroy => true
end

