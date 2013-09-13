module OregonDigital
  module Collection
    extend ActiveSupport::Concern

    included do
      has_many :members, :property => :is_member_of_collection, :class_name => "ActiveFedora::Base"
      before_destroy :remove_members
    end

    # # Returns all objects that reference this collection via OD:Set.
    # def members(force_reload = false)
    #   return @objects if @objects && !force_reload
    #   @objects = ActiveFedora::Base.find('desc_metadata__set_teim' => pid).map { |x| x.adapt_to_cmodel }
    #   @objects
    # end

    # def object_ids
    #   # Take advantage of pre-loaded objects if we can.
    #   return @objects.map { |x| x.pid } if @objects
    #   ActiveFedora::SolrService
    #     .query("desc_metadata__set_teim:#{ActiveFedora::SolrService.escape_uri_for_query(pid)}", :fl => 'id')
    #     .map { |x| x['id'] }
    # end

    # def update_member_relationships(forced_ids = {})
    #   clear_relationship(:has_member)
    #   forced = []
    #   remove = []
    #   if forced_ids[:force_add] && forced_ids[:force_add].kind_of?(Array)
    #     forced |= forced_ids[:force_add]
    #   end
    #   if forced_ids[:force_remove] && forced_ids[:force_remove].kind_of?(Array)
    #     remove |= forced_ids[:force_remove]
    #   end
    #   member_ids = (object_ids | forced) - remove
    #   member_ids.each do |id|
    #     add_relationship(:has_member, "info:fedora/#{id}")
    #   end
    # end

    def remove_all_members
      members.each do |member|
        # TODO: delete members
      end
    end
  end
end
