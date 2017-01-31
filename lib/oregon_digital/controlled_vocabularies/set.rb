module OregonDigital::ControlledVocabularies
  class Set < OregonDigital::RDF::ObjectResource
    include OregonDigital::RDF::Controlled

    def self.repository
      :parent
    end

    use_vocabulary :set
  end
end
