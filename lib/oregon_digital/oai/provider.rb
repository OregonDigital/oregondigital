class OregonDigital::OAI::Provider < ::OAI::Provider::Base
  repository_name APP_CONFIG['oai']['repository_name']
  repository_url APP_CONFIG['oai']['repository_url']
  record_prefix APP_CONFIG['oai']['record_prefix']
  admin_email APP_CONFIG['oai']['admin_email']
  sample_id APP_CONFIG['oai']['sample_id']
  source_model ::OregonDigital::OAI::Model::ActiveFedoraWrapper.new(::ActiveFedora::Base, :limit => 50)
  Base.register_format(OregonDigital::OAI::DublinCore.instance)
  Base.register_format(OregonDigital::OAI::QualifiedDublinCore.instance)

  OAI::Provider::Response::RecordResponse.class_eval do
    def identifier_for(record)
      begin
        setid = record.primarySet.split("/").last.gsub("oregondigital:","")
      rescue
        setid = record.sets.first.spec.gsub("oregondigital:","")
      ensure
        return "#{APP_CONFIG['oai']['record_prefix']}:#{setid}/#{record.id.gsub('oregondigital:','')}"
      end
    end
  end

end
