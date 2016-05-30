class CreateImageFiles < ActiveRecord::Migration
  def change
    create_table :image_files do |t|
      t.string :filename, :null => false
      t.references :file_dir, :null => false

      t.datetime :file_modified_time, :null => false
      t.string :format, :null => false
      t.integer :columns, :null => false
      t.integer :rows, :null => false
      t.integer :depth, :null => false
      t.integer :number_colors, :null => false
      t.integer :filesize, :null => false
      t.float :x_resolution, :null => false
      t.float :y_resolution, :null => false
      t.string :units
      t.string :mime_type, :limit => 50, :null => false

      t.timestamps
    end
    add_index :image_files, [:file_dir_id, :filename], :unique => true
  end
end
