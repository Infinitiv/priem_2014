# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition do
    competition_item nil
    priority 1
    admission_date "2014-06-26"
  end
end
