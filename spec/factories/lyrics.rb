# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lyric do
    l_artist "MyString"
    l_song "MyString"
    text "MyText"
    l_url "MyString"
    artist nil
    song nil
  end
end
