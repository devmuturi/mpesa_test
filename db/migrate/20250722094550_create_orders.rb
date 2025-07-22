class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :phone_number
      t.integer :total_amount
      t.string :status
      t.string :checkout_request_id
      t.string :receipt

      t.timestamps
    end
  end
end
