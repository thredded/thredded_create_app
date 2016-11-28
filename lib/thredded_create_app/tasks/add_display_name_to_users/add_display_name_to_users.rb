# frozen_string_literal: true
class AddDisplayNameToUsers < ActiveRecord::Migration[5.0]
  def up
    case connection.adapter_name.to_s
    when /mysql/i
      add_column :users, :display_name, :string, limit: 191
    when /sqlite/i
      add_column :users, :display_name, :string
      change_column_null :users, :display_name, false
    else
      add_column :users, :display_name, :string, null: false
    end

    DbTextSearch::CaseInsensitive.add_index connection, :users, :display_name,
                                            unique: true
  end

  def down
    remove_column :users, :display_name
  end
end
