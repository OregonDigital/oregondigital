FactoryGirl.define do
  factory :generic_collection, parent: :active_fedora_base, class: GenericCollection do
    sequence(:title) {|n| "Generic Collection #{n}"}
    after(:build) {|obj| obj.review}
    trait :pending_review do
      after(:build) do |obj|
        obj.reset_workflow
      end
    end
  end
end
