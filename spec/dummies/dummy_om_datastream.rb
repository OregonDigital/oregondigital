require 'active-fedora'
class DummyOmDatastream < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3")
    t.title

    # The underscore is purely to avoid namespace conflicts.
    t.name_ {
      t.namePart
      t.family_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.given_name(:path=>"namePart", :attributes=>{:type=>"given"})
      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
        t.code(:path=>"roleTerm",:attributes=>{:type=>"code"})
      }
    }
  end
  def self.xml_template
    Nokogiri::XML.parse('<mods xmlns="http://www.loc.gov/mods/v3"/>')
  end
end