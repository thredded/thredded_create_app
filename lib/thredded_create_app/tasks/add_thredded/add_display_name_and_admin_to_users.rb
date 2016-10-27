# frozen_string_literal: true
class AddDisplayNameAndAdminToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :display_name, :text, null: false
    DbTextSearch::CaseInsensitive.add_index connection, :users, :display_name,
                                            unique: true
    add_column :users, :admin, :boolean, null: false, default: false
  end

  def down
    remove_column :users, :display_name
    remove_column :users, :admin
  end
end
