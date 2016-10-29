# frozen_string_literal: true
class AddDisplayNameToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :display_name, :text, null: false
    DbTextSearch::CaseInsensitive.add_index connection, :users, :display_name,
                                            unique: true
  end

  def down
    remove_column :users, :display_name
  end
end
