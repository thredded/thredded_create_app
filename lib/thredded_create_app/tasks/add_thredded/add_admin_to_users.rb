# frozen_string_literal: true
class AddAdminToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :admin, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :admin
  end
end
