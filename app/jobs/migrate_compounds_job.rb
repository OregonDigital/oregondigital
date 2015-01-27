class MigrateCompoundsJob
  @queue = :reindex
  def self.perform
    all_old_compounds = ActiveFedora::SolrService.query("desc_metadata__od_content_references_ssim:['' TO *]", :fl => "id", :rows => 10000000).map{|x| x["id"]}
    all_old_compounds.each do |pid|
      begin
        old_compound = ActiveFedora::Base.find(pid)
        new_graph = OregonDigital::RDF::ComplexGraphConverter.new(old_compound.resource).run
        old_compound.resource.clear
        old_compound.resource << new_graph
        old_compound.save
      rescue
      end
    end
  end
end
