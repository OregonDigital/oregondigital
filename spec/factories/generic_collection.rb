FactoryGirl.define do
  factory :generic_collection, parent: :active_fedora_base, class: GenericCollection do
    sequence(:title) {|n| "Generic Collection #{n}"}
  end
end
