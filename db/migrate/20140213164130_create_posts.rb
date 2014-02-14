class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :text
      t.float :rate
      t.boolean :manual_check
      t.integer :pid, :limit => 8
      t.string :link
    end
    add_index :posts, :pid
    add_index :posts, :id
  end
end
