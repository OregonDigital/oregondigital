
desc 'Create a sitemap for OregonDigital'

def gen_map_start(f)
    home_priority = "1.0"
    setlist_priority = "0.9"

    f.puts '<?xml version="1.0" encoding="UTF-8"?>'
    f.puts '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    f.puts "<url><loc>http://oregondigital.org/catalog</loc><priority>#{home_priority}</priority></url>"
    f.puts "<url><loc>http://oregondigital.org/sets</loc><priority>#{setlist_priority}</priority></url>"
end

def gen_map_body(f, args={})
  setlanding_priority = "0.75"

  qry_assets = "active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection AND reviewed_ssim:true AND read_access_group_ssim:public"
  qry_sets = "active_fedora_model_ssi:GenericCollection AND reviewed_ssim:true"

  ActiveFedora::SolrService.query(qry_sets, :fl=> "id", :rows=>1000).map{|x| x["id"]}.each do |pid|
    setname = pid.split(":")[1].strip
    f.puts "<url><loc>http://oregondigital.org/sets/#{setname}</loc><priority>#{setlanding_priority}</priority></url>"
  end

  ActiveFedora::SolrService.query(qry_assets, :fl => "id", :rows => 1000000).map{|x| x["id"]}.each do |pid|
    f.puts "<url><loc>http://oregondigital.org/catalog/#{pid}</loc></url>"
  end

  f.puts "</urlset>"

end

task :sitemap_initial do
  filepath ='tmp/sitemap.xml'
  f = File.open(filepath,'w')
  gen_map_start(f)
  gen_map_body(f)
  f.close
end


