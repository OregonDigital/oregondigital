FactoryGirl.define do
  factory :generic_collection do
    ignore do
      pid "oregondigital:foo"
    end

    sequence(:title) {|n| "Generic Collection #{n}"}

    trait :has_pid do
      initialize_with { GenericCollection.new(pid: pid) }
    end
  end
end

