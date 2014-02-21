FactoryGirl.define do
  factory :template, parent: :active_fedora_base, class: Template do
    sequence(:name) { |n| "Test template %04d" % n }
    title ["Test title", "Another"]
    sequence(:created) { |n| (Date.today - 1000 + n).to_s }

    trait :with_description do
      description "Foo"
    end
  end
end
