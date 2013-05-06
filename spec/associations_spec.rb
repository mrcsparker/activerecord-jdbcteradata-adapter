require 'spec_helper'

require 'models/purchase_orders'

describe 'AssociationsSpec' do
  before(:all) do
    CreateVendors.up
    CreateProducts.up
    CreatePurchaseOrders.up
    CreateOrderLineItems.up
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

  describe '#accepts_nested_attibutes_for' do
    it 'should be able to create a purchase_order with line_items' do
      vendor = Vendor.new(:name => 'Test vendor', :catch_phrase => 'Hello, world')
      vendor.products.build(:name => 'Test product', :price => 100.00)
      vendor.save

      params = { :purchase_order => {
        :product_id => vendor.products.first.id,
        :code => 'Order 2',
        :quantity => 1,
        :order_line_items_attributes => [ 
          { :item_name => 'Test item' } 
        ]
      } }

      purchase_order = PurchaseOrder.create(params[:purchase_order])
      purchase_order.order_line_items.size.should == 1
    end
  end

  after(:all) do
    CreateVendors.down
    CreateProducts.down
    CreatePurchaseOrders.down
    CreateOrderLineItems.down
  end
end
