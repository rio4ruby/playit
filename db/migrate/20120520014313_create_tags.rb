class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, :limit => 4, :null => false
      t.string :value, :null => false

      t.timestamps
    end
    add_index :tags, [:name, :value], :unique => true
  end
end
