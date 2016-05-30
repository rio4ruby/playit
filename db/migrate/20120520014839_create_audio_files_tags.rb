class CreateAudioFilesTags < ActiveRecord::Migration
  def change
    create_table :audio_files_tags do |t|
      t.references :audio_file, :null => false
      t.references :tag, :null => false

      t.timestamps
    end
    add_index :audio_files_tags, [:audio_file_id, :tag_id], :unique => true
  end
end
