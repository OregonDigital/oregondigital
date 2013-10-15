# This is a high-level factory with items common to any ActiveFedora object, but shouldn't be
# instantiated directly!
FactoryGirl.define do
  factory :active_fedora_base do
    ignore do
      pid "oregondigital:foo"
    end

    trait :has_pid do
      initialize_with { new(pid: pid) }
    end
  end
end
