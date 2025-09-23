class AddPublicToTodos < ActiveRecord::Migration[8.0]
  def change
    add_column :todos, :public, :boolean, default: false
  end
end
