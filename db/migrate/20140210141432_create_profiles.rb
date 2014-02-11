class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :uid
      t.string :name
      t.boolean :ph_manual
      t.timestamps
    end
    add_index :profiles, :uid, :unique => true
  end
end
