module OregonDigital
  module Set
    extend ActiveSupport::Concern
    included do
      # Fix deep indexes on members when a set changes.
      before_save :check_update_members
      after_save :update_members
      after_destroy :update_members!
    end

    def members
      @members ||= ActiveFedora::Base.where(Solrizer.solr_name("desc_metadata__set", :facetable) => resource.rdf_subject.to_s)
    end

    def reload
      @members = nil
      super
    end

    def check_update_members
      @check_update_members = descMetadata.content_changed?
      true
    end

    def update_members!
      @check_update_members = true
      update_members
    end

    def update_members
      if @check_update_members
        @check_update_members = nil
        first_member = members.first
        if first_member.respond_to?(:queue_fetch,true)
          first_member.send(:queue_fetch)
        end
      end
    end

  end
end
