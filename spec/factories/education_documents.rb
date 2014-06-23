# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :education_document do
    education_document_type nil
    series "MyString"
    number "MyString"
    date "2014-06-23"
  end
end
