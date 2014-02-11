class AddTestFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :ph_percent, :decimal
    add_column :profiles, :right, :boolean
  end
end
