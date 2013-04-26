require 'spec_helper'

require 'models/purchase_orders'

describe 'AssociationsSpec' do
  before(:all) do
    CreateVendors.up
    CreateProducts.up
    CreatePurchaseOrders.up
  end

  it 'should create all of the tables' do
    vendor = Vendor.new(:name => 'Test vendor', :catch_phrase => 'Hello, world')
    vendor.products.build(:name => 'Test product', :price => 100.00)
    vendor.save

    vendor.products.count.should == 1

    purchase_order = PurchaseOrder.new
    purchase_order.product = vendor.products.first

    purchase_order.code = 'ORDER1'
    purchase_order.quantity = 2
    purchase_order.save

    vendor.purchase_orders.count.should == 1
  end

  after(:all) do
    CreateVendors.down
    CreateProducts.down
    CreatePurchaseOrders.down
  end
end
