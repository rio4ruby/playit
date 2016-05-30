# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list_node do
    ancestry "MyString"
    ancestry_depth 1
    position 1
    listable nil
  end
end
