class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false
      t.integer :priority, default: 3
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :todos, :completed
    add_index :todos, :priority
  end
end
