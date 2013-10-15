FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "test#{n}@test.org"}
    password "password"

    factory :admin do
      after(:build) do |user|
        user.roles << FactoryGirl.build(:role, name: "admin")
      end
    end
  end
end
