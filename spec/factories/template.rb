FactoryGirl.define do
  factory :template, parent: :active_fedora_base, class: Template do
    sequence(:title) { |n| "Test template %04d" % n }

    after(:build) do |template|
      template.templateMetadata.title = ["Test title", "Another"]
      template.templateMetadata.created = (Date.today - rand(100)).to_s
    end

    trait :with_description do
      after(:build) do |template|
        template.templateMetadata.description = "Foo"
      end
    end
  end
end
