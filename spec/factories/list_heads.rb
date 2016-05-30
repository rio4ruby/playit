# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list_head do
    user nil
    name "MyString"
    playing false
  end
end
