module Hyrax::Migrator
  module RemediationMethods

    def set_remediation(remediation_list)
      remediation_list.nil? ? [] : remediation_list.split('|')
    end

    def remediate(remediation, graph)
      dup = graph.dup
      remediation.each do |method|
        dup = send(method.to_sym, dup)
      end
      dup
    end

    def fix_geonames(graph)
      graph.statements.select{|s| s.object.to_s.include? 'geonames'}.each do |s|
        next if s.object.to_s.include? 'https'

        uri = s.object.to_s.gsub('http', 'https')
        graph << RDF::Statement(s.subject, s.predicate, RDF::URI(uri))
        graph.delete s
      end
      graph
    end
  end
end
