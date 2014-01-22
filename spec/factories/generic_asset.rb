# For some reason, Rails.root is empty...?
ROOT = File.expand_path(File.dirname(__FILE__) + "/../..")

FactoryGirl.define do
  factory :generic_asset, parent: :active_fedora_base, class: GenericAsset do
    sequence(:title) {|n| "Generic Asset #{n}"}
    read_groups ["public"]
    sequence(:created) { |n| (Date.today - 1000 + n).to_s }

    after(:build) {|obj| obj.review}

    trait :with_image_datastream do
      after(:build) do |obj|
        obj.add_file_datastream(
          File.open("#{ROOT}/spec/fixtures/fixture_image.jpg", "rb").read,
          dsid: "content",
          mimeType: "image/jpeg",
          label: "image.jpg"
        )
      end
    end

    trait :with_pdf_datastream do
      after(:build) do |obj|
        obj.add_file_datastream(
          File.open("#{ROOT}/spec/fixtures/fixture_pdf.pdf", "rb").read,
          dsid: "content",
          mimeType: "application/pdf",
          label: "doc.pdf"
        )
      end
    end

    trait :pending_review do
      after(:build) do |obj|
        obj.reset_workflow
      end
    end

    trait :in_collection! do
      after(:build) do |obj|
        obj.collections << build(:generic_collection)

        # ActiveFedora sort of requires this, so unfortunately there's no build-only option here :(
        obj.save
        obj.reload
      end
    end

    factory :image, class: Image do
      sequence(:title) {|n| "Image #{n}"}
    end

    factory :document, class: Document do
      sequence(:title) {|n| "Document #{n}"}
    end
  end
end
