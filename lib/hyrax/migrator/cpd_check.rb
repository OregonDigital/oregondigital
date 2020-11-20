
module Hyrax::Migrator
  class CpdCheck
    attr_accessor :work
    def initialize(pidlist)
      @pidlist = pidlist
      @batch_set = init_batch
    end

    def init_batch
      batch = Set.new
      File.foreach(@pidlist) do |pid|
        batch << pid.strip.gsub('oregondigital:', '')
      end
      batch
    end

    def check_cpd
      cpd_set = query_graph
      return '' if cpd_set.empty?

      message = cpd_set <= @batch_set ? 'cpd' : 'cpd children missing'
      message
    end

    def query_graph
      pids = Set.new
      statements = @work.descMetadata.graph.query(:predicate => RDF::URI("http://opaquenamespace.org/ns/contents"))
      return pids if statements.empty?

      statements.each do |s|
        pids << s.object.to_s.split(':').last
      end
      pids
    end
  end
end
