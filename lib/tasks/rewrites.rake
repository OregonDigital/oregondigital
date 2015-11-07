desc 'Generates NGINX Rewrite Rules into tmp/oregondigital.map'

task :generate_rewrites => :environment do
  OregonDigital::RewriteGenerator.call
end
