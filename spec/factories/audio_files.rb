# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :audio_file do
    filename "MyString"
    file_dir nil
    file_size 1
    file_modified_time "2012-05-19 18:44:57"
    artist nil
    album nil
    song nil
    genre nil
    tracknum 1
    bitrate 1
    samplerate 1
    length 1.5
    layer 1
    mpeg_version 1
    vbr false
    audio_start 1
    audio_length 1
    mime_type "MyString"
  end
end
