class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :num
      t.string :receipient
      t.string :tel
      t.string :address
      t.text :note
      t.belongs_to :user, null: false, foreign_key: true
      t.string :status, default: 'pending'
      t.datetime :paid_at
      t.string :transaction_id
      t.datetime :delete_at

      t.timestamps
    end
  end
end
