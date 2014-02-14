class ChangePIdtoString < ActiveRecord::Migration
  def up
    change_column :posts, :pid, :string
  end

  def down
    change_column :posts, :pid, :integer, :limit => 8
  end
end
