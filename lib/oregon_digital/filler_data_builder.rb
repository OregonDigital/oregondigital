require 'factory_girl_rails'

module OregonDigital
  class FillerDataBuilder
    def self.call(opts={})
      opts ||= {}
      new(opts).run
    end

    attr_reader :options

    def initialize(opts={})
      @options = default_options.merge(opts)
    end

    def run
      @collections = build_collections
    end

    private

      def build_collections
        collections = []
        @options[:collections].each do |collection_config|
          collection = FactoryGirl.build(:generic_collection)
          collection.institution = OregonDigital::ControlledVocabularies::Organization.new(collection_config[:institution]) if collection_config[:institution]
          collection.review!
          collections << collection
          if [:model, :elements].all?{|s| collection_config.key? s}
            build_items(collection, collection_config[:model], collection_config[:elements], collection_config[:traits])
          end
        end
        return collections
      end

      def build_items(collection, model, elements, traits)
        traits ||= []
        elements.times do
          object = FactoryGirl.build(model, *traits)
          object.set = collection
          object.review!
          object.create_derivatives
        end
      end

      def default_options
        {
          :collections => [
            {
              :institution => "University_of_Oregon",
              :model => "document",
              :elements => 3,
              :traits => [:with_pdf_datastream]
            },
            {
              :institution => "Oregon_State_University",
              :model => "image",
              :elements => 3,
              :traits => [:with_tiff_datastream ]
            }
          ]
        }
      end
  end
end
