desc 'Generates NGINX Rewrite Rules into tmp/hydra_rewrite_rules.conf'

task :generate_rewrites => :environment do
  OregonDigital::RewriteGenerator.call
end
