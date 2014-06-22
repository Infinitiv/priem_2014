# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :auth_datum, :class => 'AuthData' do
    login "MyString"
    password "MyString"
    institution_id 1
  end
end
