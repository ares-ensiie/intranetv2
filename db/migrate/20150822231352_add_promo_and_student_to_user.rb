class AddPromoAndStudentToUser < ActiveRecord::Migration
  def change
    add_column :users, :promo, :integer
    add_column :users, :student, :boolean
  end
end
