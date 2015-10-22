class AddCvToUsers < ActiveRecord::Migration
  def self.up
    add_attachment :users, :cv
  end

  def self.down
    remove_attachment :users, :cv
  end
end
