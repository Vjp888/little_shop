class CreateCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.integer :type
      t.integer :amount_off

      t.references :merchant, foreign_key: {to_table: :users}
    end
  end
end
